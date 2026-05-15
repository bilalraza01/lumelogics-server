module Outreel
  # Pushes a batch of Prospects to a Smartlead campaign. Runs preflight first,
  # logs blocked prospects, then chunks the rest at 400 leads/req with a 0.25s
  # sleep to respect Smartlead's 10 req / 2s rate limit.
  class PushService
    CHUNK_SIZE = 400

    def self.call(prospect_ids:, smartlead_campaign_id:)
      new(prospect_ids, smartlead_campaign_id).call
    end

    def initialize(prospect_ids, smartlead_campaign_id)
      @prospect_ids = Array(prospect_ids).map(&:to_i).uniq
      @smartlead_campaign_id = smartlead_campaign_id.to_i
    end

    def call
      preflight  = PreflightService.check(@prospect_ids, @smartlead_campaign_id)
      ready_ids  = preflight[:ready]
      blocked    = preflight[:blocked]

      log_blocked!(blocked)

      pushed       = []
      errors       = []
      campaign_name = SmartleadCampaign.find_by(smartlead_id: @smartlead_campaign_id)&.name

      ready_prospects    = Prospect.where(id: ready_ids).index_by(&:id)
      videos_by_prospect = Video.where(prospect_id: ready_ids, status: "ready")
                                .order(created_at: :desc)
                                .group_by(&:prospect_id)
                                .transform_values(&:first)

      ready_ids.each_slice(CHUNK_SIZE) do |chunk_ids|
        leads = chunk_ids.map { |id| build_lead(ready_prospects[id], videos_by_prospect[id]) }

        begin
          response = SmartleadClient.add_leads(@smartlead_campaign_id, leads)
          chunk_ids.each_with_index do |id, idx|
            prospect = ready_prospects[id]
            video    = videos_by_prospect[id]
            CampaignPush.create!(
              prospect:                prospect,
              video:                   video,
              smartlead_campaign_id:   @smartlead_campaign_id,
              smartlead_campaign_name: campaign_name,
              status:                  "success",
              response_payload:        { lead: leads[idx], response: response },
              pushed_at:               Time.current,
            )
            Activity.log!(prospect, "pushed_to_campaign", {
              smartlead_campaign_id: @smartlead_campaign_id,
              campaign_name:         campaign_name,
              video_id:              video&.id,
              slug:                  video&.slug,
            })
            if prospect.status == "not_contacted"
              prospect.update!(status: "sent")
              Activity.log!(prospect, "status_changed", { from: "not_contacted", to: "sent" })
            end
            pushed << id
          end
        rescue SmartleadClient::Error => e
          chunk_ids.each do |id|
            prospect = ready_prospects[id]
            CampaignPush.create!(
              prospect:                prospect,
              video:                   videos_by_prospect[id],
              smartlead_campaign_id:   @smartlead_campaign_id,
              smartlead_campaign_name: campaign_name,
              status:                  "failed",
              response_payload:        { error: e.message },
            )
            Activity.log!(prospect, "push_failed", {
              smartlead_campaign_id: @smartlead_campaign_id, error: e.message,
            })
          end
          errors << { campaign_id: @smartlead_campaign_id, chunk: chunk_ids, error: e.message }
        end

        sleep 0.25
      end

      {
        pushed:                  pushed,
        blocked:                 blocked,
        errors:                  errors,
        smartlead_campaign_id:   @smartlead_campaign_id,
        smartlead_campaign_name: campaign_name,
      }
    end

    private

    def log_blocked!(blocked)
      blocked.each do |b|
        prospect = Prospect.find_by(id: b[:prospect_id])
        next unless prospect
        CampaignPush.create!(
          prospect:              prospect,
          smartlead_campaign_id: @smartlead_campaign_id,
          status:                "skipped",
          skip_reason:           b[:reasons].join(","),
        )
        Activity.log!(prospect, "push_skipped", {
          smartlead_campaign_id: @smartlead_campaign_id, reasons: b[:reasons],
        })
      end
    end

    def build_lead(prospect, video)
      {
        email:         prospect.email,
        first_name:    prospect.first_name,
        last_name:     prospect.last_name,
        company_name:  prospect.company_name,
        website:       prospect.website,
        linkedin_url:  prospect.linkedin_url,
        custom_fields: {
          gif_url:    video&.gif_url,
          video_link: video&.player_url,
        }.compact,
      }.compact
    end
  end
end
