FactoryBot.define do
  factory :lead_magnet_request do
    lead_magnet
    sequence(:email) { |n| "prospect#{n}@example.com" }
  end
end
