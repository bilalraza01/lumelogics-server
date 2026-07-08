class FintagicContactEmailJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(submission_id)
    submission = ContactSubmission.find(submission_id)
    FintagicContactEmailSender.new(submission).call
  end
end
