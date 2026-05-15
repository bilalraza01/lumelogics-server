require "rails_helper"

RSpec.describe "Api::V1::Admin::Leads", type: :request do
  let(:secret) { "test_secret_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
  let(:admin)  { create(:admin_user) }

  around do |example|
    old = ENV["ADMIN_JWT_SECRET"]
    ENV["ADMIN_JWT_SECRET"] = secret
    example.run
    ENV["ADMIN_JWT_SECRET"] = old
  end

  def auth_header
    token, _ = AdminJwt.encode(admin)
    { "Authorization" => "Bearer #{token}" }
  end

  describe "GET /api/v1/admin/leads" do
    it "401s without a token" do
      get "/api/v1/admin/leads"
      expect(response).to have_http_status(:unauthorized)
    end

    it "aggregates requests by email with verified + request counts" do
      magnet = create(:lead_magnet)
      other_magnet = create(:lead_magnet)

      # Lead A: 2 requests, 1 verified
      create(:lead_magnet_request, lead_magnet: magnet, email: "alice@example.com",
                                   verified_at: 1.hour.ago, created_at: 2.days.ago)
      create(:lead_magnet_request, lead_magnet: other_magnet, email: "alice@example.com",
                                   created_at: 1.hour.ago)
      # Lead B: 1 unverified
      create(:lead_magnet_request, lead_magnet: magnet, email: "bob@example.com",
                                   created_at: 3.days.ago)

      get "/api/v1/admin/leads", headers: auth_header

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["pagination"]).to include("page" => 1, "total" => 2)

      # Sorted by last_seen_at DESC — alice is first (newest request 1hr ago)
      emails = body["data"].map { |r| r["email"] }
      expect(emails).to eq(%w[alice@example.com bob@example.com])

      alice = body["data"].first
      expect(alice).to include(
        "email" => "alice@example.com",
        "request_count" => 2,
        "verified_count" => 1,
      )
    end

    it "filters by q case-insensitively" do
      magnet = create(:lead_magnet)
      create(:lead_magnet_request, lead_magnet: magnet, email: "alice@example.com")
      create(:lead_magnet_request, lead_magnet: magnet, email: "bob@example.com")

      get "/api/v1/admin/leads", params: { q: "ALICE" }, headers: auth_header

      expect(response).to have_http_status(:ok)
      emails = response.parsed_body["data"].map { |r| r["email"] }
      expect(emails).to eq(%w[alice@example.com])
    end
  end

  describe "GET /api/v1/admin/leads/:email" do
    it "returns the full request list for an email" do
      magnet1 = create(:lead_magnet, slug: "playbook", title: "Playbook")
      magnet2 = create(:lead_magnet, slug: "checklist", title: "Checklist")

      create(:lead_magnet_request, lead_magnet: magnet1, email: "alice@example.com",
                                   verified_at: 1.hour.ago, created_at: 2.days.ago)
      create(:lead_magnet_request, lead_magnet: magnet2, email: "alice@example.com",
                                   created_at: 1.hour.ago, referral_source: "newsletter")

      get "/api/v1/admin/leads/#{CGI.escape('alice@example.com')}", headers: auth_header

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to include(
        "email" => "alice@example.com",
        "request_count" => 2,
        "verified_count" => 1,
      )

      # Sorted by created_at DESC
      expect(body["requests"].map { |r| r.dig("magnet", "slug") }).to eq(%w[checklist playbook])
      expect(body["requests"].first["referral_source"]).to eq("newsletter")
      expect(body["requests"].last["verified_at"]).to be_present
    end

    it "404s for an unknown email" do
      get "/api/v1/admin/leads/#{CGI.escape('ghost@example.com')}", headers: auth_header
      expect(response).to have_http_status(:not_found)
    end

    it "handles emails with + tag" do
      magnet = create(:lead_magnet)
      create(:lead_magnet_request, lead_magnet: magnet, email: "alice+work@example.com")

      get "/api/v1/admin/leads/#{CGI.escape('alice+work@example.com')}", headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["email"]).to eq("alice+work@example.com")
    end
  end
end
