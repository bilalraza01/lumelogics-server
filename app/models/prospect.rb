class Prospect < ApplicationRecord
  EMAIL_REGEX = /\A[^\s@]+@[^\s@]+\.[^\s@]+\z/

  STATUSES = %w[not_contacted sent viewed replied call_booked won lost].freeze

  enum :status, STATUSES.index_with(&:itself), validate: true

  has_many :videos,          dependent: :destroy
  has_many :activities,      dependent: :destroy
  has_many :campaign_pushes, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: EMAIL_REGEX }

  before_validation :normalize_email

  def active_video
    videos.where(status: "ready").order(created_at: :desc).first
  end

  def display_name
    [first_name, last_name].compact_blank.join(" ").presence || email
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
