require "rails_helper"
require "jwt"

RSpec.describe "GET /api/v1/admin/assessments", type: :request do
  let(:secret) { "test_secret_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }

  around do |example|
    old = ENV["ADMIN_JWT_SECRET"]
    ENV["ADMIN_JWT_SECRET"] = secret
    example.run
    ENV["ADMIN_JWT_SECRET"] = old
  end

  def auth_header(payload = { admin: true })
    token = JWT.encode(payload, secret, "HS256")
    { "Authorization" => "Bearer #{token}" }
  end

  it "returns 401 without a token" do
    get "/api/v1/admin/assessments"
    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["error"]).to eq("missing_authorization")
  end

  it "returns 401 with an invalid signature" do
    bad_token = JWT.encode({ admin: true }, "wrong_secret", "HS256")
    get "/api/v1/admin/assessments", headers: { "Authorization" => "Bearer #{bad_token}" }
    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["error"]).to eq("invalid_token")
  end

  it "lists assessments with pagination metadata for a valid token" do
    create_list(:assessment, 3)

    get "/api/v1/admin/assessments", headers: auth_header

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["data"].length).to eq(3)
    expect(body["pagination"]).to include(
      "page" => 1, "per_page" => 50, "total" => 3,
    )
    expect(body["data"].first.keys).to include(
      "id", "email", "total_score", "archetype", "created_at",
    )
  end

  it "filters by archetype when given" do
    create(:assessment, archetype: "wishful_thinker", total_score: 10)
    create(:assessment, archetype: "build_ready_operator", total_score: 80)

    get "/api/v1/admin/assessments",
      params: { archetype: "wishful_thinker" },
      headers: auth_header

    expect(response.parsed_body["data"].map { |a| a["archetype"] }).to all(eq("wishful_thinker"))
  end

  describe "GET /api/v1/admin/assessments/:id" do
    it "returns the full record with answers" do
      a = create(:assessment, answers: { "q1" => 5, "q2" => 3 })

      get "/api/v1/admin/assessments/#{a.id}", headers: auth_header

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["id"]).to eq(a.id)
      expect(body["answers"]).to eq("q1" => 5, "q2" => 3)
      expect(body["result_token"]).to eq(a.result_token)
    end

    it "404s for an unknown id" do
      get "/api/v1/admin/assessments/#{SecureRandom.uuid}", headers: auth_header
      expect(response).to have_http_status(:not_found)
    end

    it "401s without a token" do
      a = create(:assessment)
      get "/api/v1/admin/assessments/#{a.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
