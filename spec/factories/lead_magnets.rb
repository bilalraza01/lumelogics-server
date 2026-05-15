FactoryBot.define do
  factory :lead_magnet do
    sequence(:slug) { |n| "test-magnet-#{n}" }
    title           { "Test Magnet" }
    description     { "A test lead magnet." }
    resource_type   { "pdf" }
    resource_url    { "/lead-magnets/test.pdf" }
    email_subject   { "Your test resource" }
    email_intro     { "Here's your link." }
  end
end
