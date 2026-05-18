FactoryBot.define do
  factory :audit do
    sequence(:slug) { |n| "test-audit-#{n}" }
    client_name  { "Test Co" }
    industry     { "Testing" }
    status       { "delivered" }
    started_on   { Date.new(2026, 4, 1) }
    completed_on { Date.new(2026, 5, 1) }
    # Minimal structurally-valid content document (passes Audit#content_shape).
    content do
      {
        "schema_version" => 1,
        "hero" => {}, "ai_moment" => {}, "journey" => {},
        "prototype" => {}, "footer" => {}, "process_map" => {},
        "report" => {},
        "findings" => { "pain_points" => [], "optimisations" => [] },
        "waste" => { "opportunities" => [] },
        "blueprint" => { "opportunities" => [] },
        "sessions" => [], "deliverables" => [], "downloads" => [],
        "categories" => [],
      }
    end
  end
end
