module Api
  module V1
    module Admin
      # Admin CRUD for client audit deliverables. The portal uses this to
      # create/list/edit/delete audits and edit the full nested `content`
      # document. Mirrors Admin::LeadMagnetsController (auth, pagination,
      # error envelope). The public read path is the separate
      # Api::V1::AuditsController#by_slug.
      class AuditsController < ApplicationController
        include AdminAuthentication

        DEFAULT_PER_PAGE = 50
        MAX_PER_PAGE     = 200

        def index
          scope    = Audit.order(updated_at: :desc)
          page     = [params[:page].to_i, 1].max
          per_page = [params[:per_page].to_i.nonzero? || DEFAULT_PER_PAGE, MAX_PER_PAGE].min
          total    = scope.count
          records  = scope.offset((page - 1) * per_page).limit(per_page)

          render json: {
            data:       records.map { |a| list_item(a) },
            pagination: { page: page, per_page: per_page, total: total },
          }
        end

        def show
          audit = Audit.find_by(id: params[:id])
          return render(json: { error: "not_found" }, status: :not_found) unless audit

          render json: serialize(audit)
        end

        def create
          audit = Audit.new(audit_params)
          if audit.save
            render json: serialize(audit), status: :created
          else
            render json: { errors: audit.errors.as_json }, status: :unprocessable_entity
          end
        end

        def update
          audit = Audit.find_by(id: params[:id])
          return render(json: { error: "not_found" }, status: :not_found) unless audit

          if audit.update(audit_params)
            render json: serialize(audit)
          else
            render json: { errors: audit.errors.as_json }, status: :unprocessable_entity
          end
        end

        def destroy
          audit = Audit.find_by(id: params[:id])
          return render(json: { error: "not_found" }, status: :not_found) unless audit

          audit.destroy
          head :no_content
        end

        private

        # Permit the scalar columns, then attach the entire `content`
        # subtree as a plain hash. Deep-permitting is safe here: the endpoint
        # is admin-authenticated and `content` is our own schema, rendered
        # read-only by the marketing app.
        def audit_params
          p = params.require(:audit)
          permitted = p.permit(:slug, :client_name, :industry, :status,
                                :started_on, :completed_on)
          if p.key?(:content)
            raw = p[:content]
            permitted[:content] =
              raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw
          end
          permitted
        end

        # List view never ships the heavy `content` document.
        def list_item(a)
          {
            id:           a.id,
            slug:         a.slug,
            client_name:  a.client_name,
            industry:     a.industry,
            status:       a.status,
            started_on:   a.started_on,
            completed_on: a.completed_on,
            updated_at:   a.updated_at.iso8601,
          }
        end

        def serialize(a)
          list_item(a).merge(
            content:    a.content,
            created_at: a.created_at.iso8601,
          )
        end
      end
    end
  end
end
