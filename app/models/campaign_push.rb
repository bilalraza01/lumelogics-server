class CampaignPush < ApplicationRecord
  STATUSES = %w[success skipped failed].freeze

  enum :status, STATUSES.index_with(&:itself), validate: true

  belongs_to :prospect
  belongs_to :video, optional: true

  validates :smartlead_campaign_id, presence: true
end
