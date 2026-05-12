class AssessmentEmailJob < ApplicationJob
  queue_as :default

  # Retry on any unexpected error from Resend (network blip, 5xx). Cap so we
  # don't keep retrying broken sends forever.
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(assessment_id)
    assessment = Assessment.find(assessment_id)
    AssessmentEmailSender.new(assessment).call
  end
end
