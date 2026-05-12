# Scores a hash of answers (q1..q18 → 0..5) into dimension scores, a total
# score (0..100), and an archetype key. Pure Ruby — no Rails dependencies
# beyond ActiveSupport's with_indifferent_access.

class AssessmentScorer
  DIMENSIONS = {
    process_clarity:        %w[q1 q4 q9 q14 q17],
    workflow_discipline:    %w[q2 q7 q11 q18],
    operational_visibility: %w[q3 q5 q8 q12 q15],
    change_readiness:       %w[q6 q10 q13 q16],
  }.freeze

  DIMENSION_MAX_PER_QUESTION = 5
  TARGET_DIMENSION_MAX = 25
  TOTAL_MAX = 100

  Result = Struct.new(:dimension_scores, :total_score, :archetype, keyword_init: true)

  def initialize(answers)
    @answers = answers.with_indifferent_access
  end

  def call
    dim_scores = DIMENSIONS.each_with_object({}) do |(dim, q_keys), h|
      raw     = q_keys.sum { |q| @answers[q].to_i }
      raw_max = q_keys.size * DIMENSION_MAX_PER_QUESTION
      scaled  = raw_max.zero? ? 0 : ((raw.to_f / raw_max) * TARGET_DIMENSION_MAX).round
      h[dim.to_s] = { "raw" => raw, "scaled" => scaled, "max" => TARGET_DIMENSION_MAX }
    end

    total = dim_scores.values.sum { |s| s["scaled"] }

    Result.new(
      dimension_scores: dim_scores,
      total_score:      total,
      archetype:        archetype_for(total),
    )
  end

  private

  def archetype_for(total)
    case total
    when 0..35   then "wishful_thinker"
    when 36..55  then "aspirational_operator"
    when 56..75  then "coordinated_operator"
    when 76..90  then "build_ready_operator"
    else              "optimization_operator"
    end
  end
end
