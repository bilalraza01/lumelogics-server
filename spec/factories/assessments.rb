FactoryBot.define do
  factory :assessment do
    sequence(:email) { |n| "owner#{n}@example.com" }

    # Default to a mid-range "Coordinated Operator" total.
    answers do
      {
        "q1" => 3, "q2" => 3, "q3" => 5, "q4" => 5, "q5" => 3,
        "q6" => 4, "q7" => 3, "q8" => 0, "q9" => 3, "q10" => 5,
        "q11" => 5, "q12" => 3, "q13" => 3, "q14" => 3, "q15" => 5,
        "q16" => 5, "q17" => 3, "q18" => 5,
      }
    end

    total_score      { 65 }
    archetype        { "coordinated_operator" }
    dimension_scores do
      {
        "process_clarity"        => { "raw" => 17, "scaled" => 17, "max" => 25 },
        "workflow_discipline"    => { "raw" => 16, "scaled" => 20, "max" => 25 },
        "operational_visibility" => { "raw" => 16, "scaled" => 16, "max" => 25 },
        "change_readiness"       => { "raw" => 17, "scaled" => 21, "max" => 25 },
      }
    end
  end
end
