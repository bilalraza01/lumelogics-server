module Api
  module V1
    # Public read-only endpoint for the video landing page at
    # https://lumelogics.com/v/<slug>. No auth — the 8-char slug is the
    # capability token. Each successful fetch logs a `video_viewed` activity
    # on the prospect (deduped per IP within a short window so a refresh
    # doesn't flood the timeline).
    class VideosController < ApplicationController
      VIEW_DEDUP_WINDOW = 30.minutes

      # GET /api/v1/videos/by-slug/:slug
      def show_by_slug
        video = Video.includes(:prospect).find_by(slug: params[:slug])
        return render(json: { error: "not_found" }, status: :not_found) unless video
        unless video.status == "ready"
          return render(json: { error: "not_ready" }, status: :not_found)
        end

        prospect = video.prospect
        record_view!(prospect, video)

        render json: {
          slug:        video.slug,
          mp4_url:     video.mp4_url,
          gif_url:     video.gif_url,
          duration_seconds: video.duration_seconds,
          prospect: {
            first_name: prospect.first_name.presence,
          },
        }
      end

      private

      def record_view!(prospect, video)
        recent_view = prospect.activities
                              .where(event_type: "video_viewed")
                              .where(occurred_at: VIEW_DEDUP_WINDOW.ago..)
                              .where("metadata ->> 'slug' = ?", video.slug)
                              .where("metadata ->> 'ip_hash' = ?", ip_hash)
                              .exists?
        return if recent_view

        Activity.log!(prospect, "video_viewed", {
          video_id:   video.id,
          slug:       video.slug,
          ip_hash:    ip_hash,
          user_agent: request.user_agent.to_s[0, 255],
          referrer:   request.referer.to_s[0, 500],
        })

        promote_to_viewed!(prospect)
      rescue StandardError => e
        # Never let view logging break the player page.
        Rails.logger.warn("video_viewed log failed: #{e.class}: #{e.message}")
      end

      # First real view from the prospect promotes the outreach status. Only
      # walks `not_contacted` and `sent` forward — leaves `replied` /
      # `call_booked` / `won` / `lost` alone (those are downstream signals,
      # don't rewind them).
      PROMOTABLE_STATUSES = %w[not_contacted sent].freeze
      def promote_to_viewed!(prospect)
        return unless PROMOTABLE_STATUSES.include?(prospect.status)

        previous = prospect.status
        prospect.update!(status: "viewed")
        Activity.log!(prospect, "status_changed", {
          from:    previous,
          to:      "viewed",
          trigger: "video_view",
        })
      end

      def ip_hash
        @ip_hash ||= begin
          salt = ENV.fetch("VIEW_IP_SALT", "dev-salt")
          Digest::SHA256.hexdigest("#{request.remote_ip}|#{salt}")
        end
      end
    end
  end
end
