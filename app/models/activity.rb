class Activity < ApplicationRecord
  belongs_to :prospect

  EVENT_TYPES = %w[
    prospect_created
    prospect_updated
    csv_imported
    video_attached
    video_ready
    video_failed
    video_viewed
    pushed_to_campaign
    push_skipped
    push_failed
    status_changed
  ].freeze

  validates :event_type, presence: true, inclusion: { in: EVENT_TYPES }

  before_validation :set_occurred_at

  scope :recent, -> { order(occurred_at: :desc) }

  def self.log!(prospect, event_type, metadata = {})
    create!(prospect: prospect, event_type: event_type, metadata: metadata)
  end

  private

  def set_occurred_at
    self.occurred_at ||= Time.current
  end
end
