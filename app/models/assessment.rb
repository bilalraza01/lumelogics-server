class Assessment < ApplicationRecord
  ARCHETYPES = %w[
    wishful_thinker
    aspirational_operator
    coordinated_operator
    build_ready_operator
    optimization_operator
  ].freeze

  before_validation :generate_result_token, on: :create

  validates :email,        presence: true, format: URI::MailTo::EMAIL_REGEXP
  validates :answers,      presence: true
  validates :total_score,  presence: true, numericality: { in: 0..100 }
  validates :archetype,    presence: true, inclusion: { in: ARCHETYPES }
  validates :result_token, presence: true, uniqueness: true

  scope :recent, -> { order(created_at: :desc) }

  def archetype_display
    archetype.split("_").map(&:capitalize).join(" ")
  end

  private

  def generate_result_token
    self.result_token ||= SecureRandom.urlsafe_base64(16)
  end
end
