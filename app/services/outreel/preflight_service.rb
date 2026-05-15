module Outreel
  # Determines which Prospects are ready to be pushed to a Smartlead campaign,
  # and which are blocked (and why).
  class PreflightService
    EMAIL_REGEX = /\A[^\s@]+@[^\s@]+\.[^\s@]+\z/

    Result = Struct.new(:ready, :blocked, keyword_init: true) do
      def to_h
        { ready: ready, blocked: blocked }
      end
    end

    def self.check(prospect_ids, smartlead_campaign_id)
      new(prospect_ids, smartlead_campaign_id).check
    end

    def initialize(prospect_ids, smartlead_campaign_id)
      @prospect_ids = Array(prospect_ids).map(&:to_i).uniq
      @smartlead_campaign_id = smartlead_campaign_id.to_i
    end

    def check
      prospects_by_id = Prospect.where(id: @prospect_ids).index_by(&:id)
      already_pushed_ids = CampaignPush
                             .where(smartlead_campaign_id: @smartlead_campaign_id, status: "success")
                             .pluck(:prospect_id)
                             .to_set

      ready   = []
      blocked = []

      @prospect_ids.each do |id|
        prospect = prospects_by_id[id]
        reasons  = []

        if prospect.nil?
          blocked << { prospect_id: id, reasons: ["not_found"] }
          next
        end

        reasons << "missing_email"        if prospect.email.blank?
        reasons << "invalid_email_format" if prospect.email.present? && prospect.email !~ EMAIL_REGEX

        video = prospect.active_video
        if video.nil?
          any_video = prospect.videos.order(created_at: :desc).first
          reasons << (any_video ? "video_not_ready" : "missing_video")
        end

        reasons << "already_pushed_to_this_campaign" if already_pushed_ids.include?(id)

        if reasons.empty?
          ready << id
        else
          blocked << { prospect_id: id, reasons: reasons }
        end
      end

      Result.new(ready: ready, blocked: blocked).to_h
    end
  end
end
