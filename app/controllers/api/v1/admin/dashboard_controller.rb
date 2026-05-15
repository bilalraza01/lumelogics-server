module Api
  module V1
    module Admin
      # Read-only aggregation across the full funnel: assessments -> magnet
      # captures -> outreach prospects -> video pipeline -> Smartlead pushes.
      # Single endpoint, single payload, no caching (counts are cheap at scale).
      class DashboardController < ApplicationController
        include AdminAuthentication

        WEEK = 7.days

        def index
          since = WEEK.ago

          render json: {
            lead_funnel:            lead_funnel(since),
            outreach_pipeline:      outreach_pipeline,
            smartlead_activity:     smartlead_activity(since),
            recent_assessments:     recent_assessments,
            recent_magnet_requests: recent_magnet_requests,
            recent_activity:        recent_activity,
          }
        end

        private

        def lead_funnel(since)
          {
            assessments_total:         Assessment.count,
            assessments_this_week:     Assessment.where(created_at: since..).count,
            assessments_by_archetype:  Assessment.group(:archetype).count,
            magnet_requests_total:     LeadMagnetRequest.count,
            magnet_requests_this_week: LeadMagnetRequest.where(created_at: since..).count,
            magnet_requests_verified:  LeadMagnetRequest.where.not(verified_at: nil).count,
            leads_total:               LeadMagnetRequest.distinct.count(:email),
            leads_this_week:           LeadMagnetRequest.where(created_at: since..).distinct.count(:email),
          }
        end

        def outreach_pipeline
          {
            prospects_total:     Prospect.count,
            prospects_by_status: Prospect.group(:status).count,
            videos_in_flight:    Video.where.not(status: %w[ready failed]).count,
            videos_failed:       Video.where(status: "failed").count,
            videos_ready:        Video.where(status: "ready").count,
          }
        end

        def smartlead_activity(since)
          recent_pushes = CampaignPush.where(created_at: since..)
          {
            pushes_this_week:       recent_pushes.count,
            pushes_by_status:       recent_pushes.group(:status).count,
            campaigns_synced_total: SmartleadCampaign.count,
          }
        end

        def recent_assessments
          Assessment.order(created_at: :desc).limit(5).map do |a|
            {
              id:          a.id,
              email:       a.email,
              archetype:   a.archetype,
              total_score: a.total_score,
              created_at:  a.created_at.iso8601,
            }
          end
        end

        def recent_magnet_requests
          LeadMagnetRequest.includes(:lead_magnet).order(created_at: :desc).limit(5).map do |r|
            {
              id:          r.id,
              email:       r.email,
              magnet:      { slug: r.lead_magnet.slug, title: r.lead_magnet.title },
              verified_at: r.verified_at&.iso8601,
              created_at:  r.created_at.iso8601,
            }
          end
        end

        def recent_activity
          Activity.includes(:prospect).order(occurred_at: :desc).limit(10).map do |ev|
            {
              id:          ev.id,
              event_type:  ev.event_type,
              prospect:    { id: ev.prospect.id, email: ev.prospect.email },
              metadata:    ev.metadata,
              occurred_at: ev.occurred_at.iso8601,
            }
          end
        end
      end
    end
  end
end
