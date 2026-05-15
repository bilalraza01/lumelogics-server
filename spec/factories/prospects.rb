FactoryBot.define do
  factory :prospect do
    sequence(:email) { |n| "prospect#{n}@example.com" }
    first_name { "Pat" }
    last_name  { "Example" }
    status     { "not_contacted" }
  end
end
