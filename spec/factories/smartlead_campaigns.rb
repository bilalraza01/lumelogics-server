FactoryBot.define do
  factory :smartlead_campaign do
    sequence(:smartlead_id) { |n| 1_000_000 + n }
    name   { "Test Campaign" }
    status { "ACTIVE" }
  end
end
