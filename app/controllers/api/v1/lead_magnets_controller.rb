module Api
  module V1
    class LeadMagnetsController < ApplicationController
      DUPLICATE_WINDOW = 1.hour

      # POST /api/v1/lead-magnets/:slug/requests
      def create_request
        magnet = LeadMagnet.find_by(slug: params[:slug])
        return render(json: { error: "magnet_not_found" }, status: :not_found) unless magnet

        email = request_params[:email].to_s.strip
        return render(json: { error: "invalid_email" }, status: :unprocessable_entity) unless email.match?(URI::MailTo::EMAIL_REGEXP)

        # Dedupe: same email + magnet within DUPLICATE_WINDOW returns the
        # existing record (and does NOT re-send) so a refresh / double-submit
        # doesn't spam the prospect.
        existing = magnet.lead_magnet_requests
                         .where(email: email.downcase)
                         .where(created_at: DUPLICATE_WINDOW.ago..)
                         .recent
                         .first

        lmr = existing || magnet.lead_magnet_requests.create!(
          email:           email.downcase,
          referral_source: request_params[:referral_source],
          ip_address:      request.remote_ip,
          user_agent:      request.user_agent,
        )

        LeadMagnetEmailJob.perform_later(lmr.id) unless existing

        render json: { status: "email_sent" }, status: existing ? :ok : :created
      end

      # GET /api/v1/lead-magnets/:slug/access/:token
      def access
        magnet = LeadMagnet.find_by(slug: params[:slug])
        return render(json: { error: "magnet_not_found" }, status: :not_found) unless magnet

        lmr = magnet.lead_magnet_requests.find_by(verification_token: params[:token])
        return render(json: { error: "not_found" }, status: :not_found) unless lmr

        lmr.mark_verified!

        render json: {
          slug:         magnet.slug,
          title:        magnet.title,
          description:  magnet.description,
          resource:     resource_payload(magnet, lmr),
          vsl: {
            video_url: magnet.vsl_video_url,
            headline:  magnet.vsl_headline,
            body:      magnet.vsl_body,
          },
          calendly_url: magnet.calendly_url_or_default,
          verified_at:  lmr.verified_at&.iso8601,
        }
      end

      # GET /api/v1/lead-magnets/:slug/download/:token
      # Streams the uploaded file with an attachment disposition so the
      # browser downloads it (works cross-origin, unlike the <a download>
      # hint). Token-gated the same way as #access.
      def download
        magnet = LeadMagnet.find_by(slug: params[:slug])
        return render(json: { error: "magnet_not_found" }, status: :not_found) unless magnet

        lmr = magnet.lead_magnet_requests.find_by(verification_token: params[:token])
        return render(json: { error: "not_found" }, status: :not_found) unless lmr

        unless magnet.downloadable?
          return render(json: { error: "not_downloadable" }, status: :unprocessable_entity)
        end

        if magnet.resource_file.present?
          path = magnet.resource_file.path
          unless path && File.exist?(path)
            return render(json: { error: "file_missing" }, status: :not_found)
          end

          send_file path,
            disposition: "attachment",
            filename:    File.basename(path),
            type:        Rack::Mime.mime_type(File.extname(path))
        elsif magnet.resource_url.present?
          # Legacy magnet still pointing at a static URL.
          redirect_to magnet.resource_url, allow_other_host: true
        else
          render(json: { error: "file_missing" }, status: :not_found)
        end
      end

      private

      def resource_payload(magnet, lmr)
        if magnet.downloadable?
          {
            type:     magnet.resource_type,
            url:      "#{request.base_url}/api/v1/lead-magnets/#{magnet.slug}/download/#{lmr.verification_token}",
            download: true,
          }
        else
          { type: magnet.resource_type, url: magnet.resource_url, download: false }
        end
      end

      def request_params
        params.permit(:email, :referral_source).to_h.symbolize_keys
      end
    end
  end
end
