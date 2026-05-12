require "rails_helper"

RSpec.describe AssessmentScorer do
  # All 5s = perfect score, except for q13 ($50K+) which is also 5.
  def all_answers(value)
    (1..18).map { |i| ["q#{i}", value] }.to_h
  end

  describe "archetype boundaries" do
    it "scores 0 (all zeros) as wishful_thinker" do
      result = described_class.new(all_answers(0)).call
      expect(result.total_score).to eq(0)
      expect(result.archetype).to eq("wishful_thinker")
    end

    it "scores all-5s as optimization_operator (100)" do
      result = described_class.new(all_answers(5)).call
      expect(result.total_score).to eq(100)
      expect(result.archetype).to eq("optimization_operator")
    end

    it "maps 35 → wishful_thinker (top of band)" do
      expect(archetype_for_total(35)).to eq("wishful_thinker")
    end

    it "maps 36 → aspirational_operator (bottom of band)" do
      expect(archetype_for_total(36)).to eq("aspirational_operator")
    end

    it "maps 55 → aspirational_operator (top)" do
      expect(archetype_for_total(55)).to eq("aspirational_operator")
    end

    it "maps 56 → coordinated_operator (bottom)" do
      expect(archetype_for_total(56)).to eq("coordinated_operator")
    end

    it "maps 75 → coordinated_operator (top)" do
      expect(archetype_for_total(75)).to eq("coordinated_operator")
    end

    it "maps 76 → build_ready_operator (bottom)" do
      expect(archetype_for_total(76)).to eq("build_ready_operator")
    end

    it "maps 90 → build_ready_operator (top)" do
      expect(archetype_for_total(90)).to eq("build_ready_operator")
    end

    it "maps 91 → optimization_operator (bottom)" do
      expect(archetype_for_total(91)).to eq("optimization_operator")
    end
  end

  describe "dimension scoring" do
    it "splits per-dimension correctly and scales 4-question dimensions to /25" do
      result = described_class.new(all_answers(5)).call
      scores = result.dimension_scores

      # 5 questions × 5 = 25 raw, scaled to 25.
      expect(scores["process_clarity"]).to    eq({ "raw" => 25, "scaled" => 25, "max" => 25 })
      expect(scores["operational_visibility"]).to eq({ "raw" => 25, "scaled" => 25, "max" => 25 })

      # 4 questions × 5 = 20 raw, scaled to 25.
      expect(scores["workflow_discipline"]).to eq({ "raw" => 20, "scaled" => 25, "max" => 25 })
      expect(scores["change_readiness"]).to     eq({ "raw" => 20, "scaled" => 25, "max" => 25 })
    end

    it "treats unknown answer values as zero" do
      result = described_class.new("q1" => nil, "q2" => "abc").call
      expect(result.total_score).to eq(0)
    end
  end

  # Helpers ------------------------------------------------------------------

  # Constructs an answer set whose scaled total lands exactly on `target`.
  # 100 max total → 100% of all 5s. So we proportionally fill q1..q18 with 5s
  # then push the last questions toward the target.
  def archetype_for_total(target)
    answers = all_answers(0)
    remaining = target

    # We'll fill dimensions one by one. Each dimension scales raw → 25.
    %i[process_clarity workflow_discipline operational_visibility change_readiness].each do |dim|
      keys = AssessmentScorer::DIMENSIONS[dim]
      raw_max = keys.size * 5
      take = [remaining, 25].min
      raw  = ((take.to_f / 25) * raw_max).round
      # Distribute raw across keys as 5s + a remainder.
      keys.each do |k|
        if raw >= 5
          answers[k] = 5
          raw -= 5
        elsif raw.positive?
          answers[k] = raw
          raw = 0
        end
      end
      remaining -= take
      break if remaining.zero?
    end

    described_class.new(answers).call.archetype
  end
end
