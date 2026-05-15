require "securerandom"

class Video < ApplicationRecord
  STATUSES = %w[
    pending
    downloading
    uploading_mp4
    generating_gif
    uploading_gif
    ready
    failed
  ].freeze

  enum :status, STATUSES.index_with(&:itself), validate: true

  belongs_to :prospect
  has_many :campaign_pushes, dependent: :nullify

  validates :slug,     presence: true, uniqueness: true
  validates :loom_url, presence: true

  before_validation :assign_slug, on: :create

  def terminal?
    status == "ready" || status == "failed"
  end

  private

  def assign_slug
    return if slug.present?
    loop do
      candidate = SecureRandom.alphanumeric(8).downcase
      break self.slug = candidate unless Video.exists?(slug: candidate)
    end
  end
end
