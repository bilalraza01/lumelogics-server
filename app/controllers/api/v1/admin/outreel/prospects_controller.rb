module Api
  module V1
    module Admin
      module Outreel
        class ProspectsController < BaseController
          before_action :find_prospect, only: %i[show update destroy]

          def index
            scope = Prospect.all

            scope = scope.where(status: params[:status]) if params[:status].present?
            scope = scope.where(batch_id: params[:batch_id]) if params[:batch_id].present?

            if params[:has_video].present?
              ready_prospect_ids = Video.where(status: "ready").select(:prospect_id)
              scope =
                if ActiveModel::Type::Boolean.new.cast(params[:has_video])
                  scope.where(id: ready_prospect_ids)
                else
                  scope.where.not(id: ready_prospect_ids)
                end
            end

            if params[:pushed_to_campaign_id].present?
              pushed = CampaignPush
                         .where(smartlead_campaign_id: params[:pushed_to_campaign_id], status: "success")
                         .select(:prospect_id)
              scope = scope.where(id: pushed)
            end

            if (q = params[:q]).present?
              like = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
              scope = scope.where(
                "email ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q OR company_name ILIKE :q",
                q: like,
              )
            end

            prospects = scope.order(created_at: :desc).limit(500)
            view_stats = batch_view_stats(prospects.map(&:id))
            render json: prospects.map { |p| serialize(p, view_stats: view_stats[p.id]) }
          end

          def show
            stats = batch_view_stats([@prospect.id])[@prospect.id]
            render json: serialize(@prospect,
              include_video: true,
              include_activities: true,
              view_stats: stats)
          end

          def create
            prospect = Prospect.new(prospect_params)
            prospect.save!
            Activity.log!(prospect, "prospect_created")
            render json: serialize(prospect), status: :created
          end

          def update
            previous_status = @prospect.status
            @prospect.update!(prospect_params)
            if previous_status != @prospect.status
              Activity.log!(@prospect, "status_changed", { from: previous_status, to: @prospect.status })
            else
              Activity.log!(@prospect, "prospect_updated", { fields: prospect_params.keys })
            end
            render json: serialize(@prospect, include_video: true)
          end

          def destroy
            @prospect.destroy!
            head :no_content
          end

          private

          def find_prospect
            @prospect = Prospect.find(params[:id])
          end

          def prospect_params
            params.require(:prospect).permit(
              :email, :first_name, :last_name, :company_name,
              :linkedin_url, :website, :notes, :status, :batch_id,
            )
          end

          # Returns { prospect_id => { count:, last_viewed_at: } } in two queries
          # so the index isn't N+1 on the activities table.
          def batch_view_stats(ids)
            return {} if ids.empty?
            scope  = Activity.where(event_type: "video_viewed", prospect_id: ids)
            counts = scope.group(:prospect_id).count
            latest = scope.group(:prospect_id).maximum(:occurred_at)
            ids.index_with do |id|
              { count: counts[id] || 0, last_viewed_at: latest[id] }
            end
          end

          def serialize(prospect, include_video: true, include_activities: false, view_stats: nil)
            data = prospect.as_json
            data["view_count"]     = view_stats&.fetch(:count, 0) || 0
            data["last_viewed_at"] = view_stats&.fetch(:last_viewed_at, nil)&.iso8601
            if include_video
              data["active_video"] = prospect.active_video&.as_json
              data["latest_video"] = prospect.videos.order(created_at: :desc).first&.as_json
            end
            if include_activities
              data["activities"] = prospect.activities.recent.limit(50).map(&:as_json)
            end
            data
          end
        end
      end
    end
  end
end
