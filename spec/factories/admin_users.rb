FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin#{n}@lumelogics.test" }
    password         { "correct-horse-battery-staple" }
  end
end
