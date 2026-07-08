# Contact form submission from the Fintagic marketing site.
# Persisted as an audit trail; the notification email to
# FintagicContactEmailSender::RECIPIENT is enqueued from the controller.

class ContactSubmission < ApplicationRecord
  before_validation :normalize_email

  validates :name,    presence: true
  validates :company, presence: true
  validates :revenue, presence: true
  validates :message, presence: true
  validates :email,   presence: true, format: URI::MailTo::EMAIL_REGEXP

  scope :recent, -> { order(created_at: :desc) }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
