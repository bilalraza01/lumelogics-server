FactoryBot.define do
  factory :video do
    prospect
    loom_url { "https://www.loom.com/share/abcdef0123456789" }
    status   { "pending" }
  end
end
