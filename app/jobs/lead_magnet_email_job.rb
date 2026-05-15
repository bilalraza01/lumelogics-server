class LeadMagnetEmailJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(request_id)
    request = LeadMagnetRequest.find(request_id)
    LeadMagnetEmailSender.new(request).call
  end
end
