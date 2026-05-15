require "rails_helper"

RSpec.describe LeadMagnetEmailJob, type: :job do
  let(:lmr) { create(:lead_magnet_request) }

  it "calls LeadMagnetEmailSender for the given request id" do
    sender = instance_double(LeadMagnetEmailSender, call: true)
    expect(LeadMagnetEmailSender).to receive(:new).with(
      have_attributes(id: lmr.id),
    ).and_return(sender)

    described_class.perform_now(lmr.id)
  end
end
