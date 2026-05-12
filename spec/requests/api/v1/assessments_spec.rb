require "rails_helper"

RSpec.describe "POST /api/v1/assessments", type: :request do
  let(:valid_answers) do
    (1..18).map { |i| ["q#{i}", 3] }.to_h
  end

  let(:valid_payload) do
    { email: "owner@example.com", answers: valid_answers }
  end

  describe "happy path" do
    it "returns 201 with the full result shape and enqueues the email job" do
      expect {
        post "/api/v1/assessments", params: valid_payload, as: :json
      }.to change(Assessment, :count).by(1)
        .and have_enqueued_job(AssessmentEmailJob)

      expect(response).to have_http_status(:created)

      body = response.parsed_body
      expect(body.keys).to include(
        "result_token",
        "total_score",
        "archetype",
        "archetype_display",
        "verdict",
        "dimension_scores",
        "cta",
        "results_url",
      )
      expect(body["result_token"]).to be_present
      expect(body["total_score"]).to be_a(Integer)
      expect(Assessment::ARCHETYPES).to include(body["archetype"])
      expect(body["cta"]).to include("label", "url")
      expect(body["dimension_scores"].keys).to match_array(%w[
        process_clarity workflow_discipline operational_visibility change_readiness
      ])
    end
  end

  describe "validation" do
    it "returns 422 on invalid email" do
      post "/api/v1/assessments",
        params: valid_payload.merge(email: "not-an-email"),
        as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["error"]).to eq("invalid_email")
    end

    it "returns 422 when answers are missing keys" do
      partial = valid_answers.except("q18")
      post "/api/v1/assessments",
        params: valid_payload.merge(answers: partial),
        as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["error"]).to eq("missing_answers")
    end

    it "returns 422 when answer values are out of range" do
      bad = valid_answers.merge("q1" => 9)
      post "/api/v1/assessments",
        params: valid_payload.merge(answers: bad),
        as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["error"]).to eq("invalid_answer_values")
    end
  end

  describe "duplicate submission within 1 hour" do
    it "returns the existing record without creating a new one" do
      post "/api/v1/assessments", params: valid_payload, as: :json
      first_token = response.parsed_body["result_token"]

      expect {
        post "/api/v1/assessments", params: valid_payload, as: :json
      }.not_to change(Assessment, :count)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["result_token"]).to eq(first_token)
    end
  end
end

RSpec.describe "GET /api/v1/assessments/:token", type: :request do
  let!(:assessment) { create(:assessment) }

  it "returns the assessment for a valid token" do
    get "/api/v1/assessments/#{assessment.result_token}"
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["result_token"]).to eq(assessment.result_token)
    expect(response.parsed_body["archetype"]).to eq(assessment.archetype)
  end

  it "returns 404 for an unknown token" do
    get "/api/v1/assessments/nope-not-a-real-token"
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body["error"]).to eq("not_found")
  end
end
