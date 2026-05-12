require "rails_helper"

RSpec.describe AssessmentEmailJob, type: :job do
  let(:assessment) { create(:assessment) }

  it "calls AssessmentEmailSender for the given assessment id" do
    sender = instance_double(AssessmentEmailSender, call: true)
    expect(AssessmentEmailSender).to receive(:new).with(
      have_attributes(id: assessment.id),
    ).and_return(sender)

    described_class.perform_now(assessment.id)
  end
end
