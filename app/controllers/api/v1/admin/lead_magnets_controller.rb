module Api
  module V1
    module Admin
      class LeadMagnetsController < ApplicationController
        include AdminAuthentication

        DEFAULT_PER_PAGE = 50
        MAX_PER_PAGE     = 200

        PERMITTED_PARAMS = %i[
          slug title description resource_type resource_url resource_file
          email_subject email_intro
          vsl_video_url vsl_headline vsl_body calendly_url
        ].freeze

        def index
          scope    = LeadMagnet.order(updated_at: :desc)
          page     = [params[:page].to_i, 1].max
          per_page = [params[:per_page].to_i.nonzero? || DEFAULT_PER_PAGE, MAX_PER_PAGE].min
          total    = scope.count
          records  = scope.offset((page - 1) * per_page).limit(per_page)

          render json: {
            data:       records.map { |m| serialize(m) },
            pagination: { page: page, per_page: per_page, total: total },
          }
        end

        def show
          magnet = LeadMagnet.find_by(id: params[:id])
          return render(json: { error: "not_found" }, status: :not_found) unless magnet

          render json: serialize(magnet)
        end

        def create
          magnet = LeadMagnet.new(magnet_params)
          if magnet.save
            render json: serialize(magnet), status: :created
          else
            render json: { errors: magnet.errors.as_json }, status: :unprocessable_entity
          end
        end

        def update
          magnet = LeadMagnet.find_by(id: params[:id])
          return render(json: { error: "not_found" }, status: :not_found) unless magnet

          if magnet.update(magnet_params)
            render json: serialize(magnet)
          else
            render json: { errors: magnet.errors.as_json }, status: :unprocessable_entity
          end
        end

        def destroy
          magnet = LeadMagnet.find_by(id: params[:id])
          return render(json: { error: "not_found" }, status: :not_found) unless magnet

          magnet.destroy
          head :no_content
        end

        private

        def magnet_params
          params.permit(*PERMITTED_PARAMS)
        end

        def serialize(magnet)
          file_url = magnet.resource_file.url
          {
            id:                 magnet.id,
            slug:               magnet.slug,
            title:              magnet.title,
            description:        magnet.description,
            resource_type:      magnet.resource_type,
            resource_url:       magnet.resource_url,
            resource_file_url:  file_url ? "#{request.base_url}#{file_url}" : nil,
            resource_file_name: magnet.resource_file_identifier,
            email_subject: magnet.email_subject,
            email_intro:   magnet.email_intro,
            vsl_video_url: magnet.vsl_video_url,
            vsl_headline:  magnet.vsl_headline,
            vsl_body:      magnet.vsl_body,
            calendly_url:  magnet.calendly_url,
            request_count: magnet.lead_magnet_requests.count,
            created_at:    magnet.created_at.iso8601,
            updated_at:    magnet.updated_at.iso8601,
          }
        end
      end
    end
  end
end
