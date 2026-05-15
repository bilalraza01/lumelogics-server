class LeadMagnetRequest < ApplicationRecord
  belongs_to :lead_magnet

  before_validation :generate_verification_token, on: :create

  validates :email,              presence: true, format: URI::MailTo::EMAIL_REGEXP
  validates :verification_token, presence: true, uniqueness: true

  scope :recent, -> { order(created_at: :desc) }
  scope :verified, -> { where.not(verified_at: nil) }

  def mark_verified!
    return if verified_at.present?

    update!(verified_at: Time.current)
  end

  private

  def generate_verification_token
    self.verification_token ||= SecureRandom.urlsafe_base64(16)
  end
end
