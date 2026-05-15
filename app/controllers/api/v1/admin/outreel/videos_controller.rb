module Api
  module V1
    module Admin
      module Outreel
        class VideosController < BaseController
          def show
            video = Video.find(params[:id])
            render json: video.as_json
          end

          def create
            prospect = Prospect.find(params[:prospect_id])

            loom_url = params.dig(:video, :loom_url).presence || params[:loom_url].presence
            batch_id = params.dig(:video, :batch_id) || params[:batch_id]
            if loom_url.blank?
              return render(json: { error: "loom_url is required" }, status: :bad_request)
            end

            video = Video.create!(
              prospect: prospect,
              loom_url: loom_url,
              batch_id: batch_id,
              status:   "pending",
            )

            prospect.update!(batch_id: batch_id) if batch_id.present?

            Activity.log!(prospect, "video_attached", {
              video_id: video.id, slug: video.slug, loom_url: loom_url, batch_id: batch_id,
            })

            AttachVideoJob.perform_later(video.id)

            render json: video.as_json, status: :created
          end
        end
      end
    end
  end
end
