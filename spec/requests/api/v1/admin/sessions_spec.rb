require "rails_helper"

RSpec.describe "POST /api/v1/admin/sessions", type: :request do
  let(:secret) { "test_secret_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }

  around do |example|
    old = ENV["ADMIN_JWT_SECRET"]
    ENV["ADMIN_JWT_SECRET"] = secret
    example.run
    ENV["ADMIN_JWT_SECRET"] = old
  end

  it "returns a token for valid credentials" do
    create(:admin_user, email: "bilal@lumelogics.com", password: "supersecret123")

    post "/api/v1/admin/sessions",
      params: { email: "bilal@lumelogics.com", password: "supersecret123" }.to_json,
      headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["token"]).to be_present
    expect(body["expires_at"]).to be_present
    expect(body.dig("admin", "email")).to eq("bilal@lumelogics.com")

    payload = AdminJwt.decode(body["token"])
    expect(payload["sub"]).to eq(body.dig("admin", "id"))
  end

  it "is case-insensitive on email" do
    create(:admin_user, email: "bilal@lumelogics.com", password: "supersecret123")

    post "/api/v1/admin/sessions",
      params: { email: "BILAL@LUMELOGICS.COM", password: "supersecret123" }.to_json,
      headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:ok)
  end

  it "returns 401 for a wrong password" do
    create(:admin_user, email: "bilal@lumelogics.com", password: "supersecret123")

    post "/api/v1/admin/sessions",
      params: { email: "bilal@lumelogics.com", password: "nope" }.to_json,
      headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["error"]).to eq("invalid_credentials")
  end

  it "returns 401 for an unknown email (no enumeration)" do
    post "/api/v1/admin/sessions",
      params: { email: "ghost@lumelogics.com", password: "whatever" }.to_json,
      headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["error"]).to eq("invalid_credentials")
  end

  it "returns 422 when email or password are missing" do
    post "/api/v1/admin/sessions",
      params: { email: "" }.to_json,
      headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body["error"]).to eq("missing_credentials")
  end
end
