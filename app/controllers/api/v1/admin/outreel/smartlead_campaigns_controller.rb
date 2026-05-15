module Api
  module V1
    module Admin
      module Outreel
        class SmartleadCampaignsController < BaseController
          rescue_from ::Outreel::SmartleadClient::Error do |e|
            render json: { error: e.message }, status: :bad_gateway
          end

          def index
            campaigns = SmartleadCampaign.order(:name).map { |c| serialize(c) }
            render json: campaigns
          end

          def sync
            payload   = ::Outreel::SmartleadClient.list_campaigns
            campaigns = payload.is_a?(Array) ? payload : (payload["campaigns"] || payload["data"] || [])

            synced = campaigns.map do |raw|
              smartlead_id = (raw["id"] || raw["campaign_id"]).to_i
              next nil if smartlead_id.zero?

              record = SmartleadCampaign.find_or_initialize_by(smartlead_id: smartlead_id)
              record.name           = raw["name"] || raw["campaign_name"]
              record.status         = raw["status"]
              record.last_synced_at = Time.current
              record.save!
              record
            end.compact

            render json: synced.map { |c| serialize(c) }
          end

          def preflight
            ids    = Array(params[:prospect_ids]).map(&:to_i)
            result = ::Outreel::PreflightService.check(ids, params[:id].to_i)
            render json: result
          end

          def push
            ids         = Array(params[:prospect_ids]).map(&:to_i)
            campaign_id = params[:id].to_i
            summary     = ::Outreel::PushService.call(prospect_ids: ids, smartlead_campaign_id: campaign_id)
            render json: summary
          end

          def analytics
            render json: ::Outreel::SmartleadClient.analytics(params[:id])
          end

          private

          def serialize(c)
            {
              id:             c.id,
              smartlead_id:   c.smartlead_id,
              name:           c.name,
              status:         c.status,
              last_synced_at: c.last_synced_at,
            }
          end
        end
      end
    end
  end
end
