require "rails_helper"

RSpec.describe "Api::V1::Admin::Outreel::Prospects", type: :request do
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
    { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
  end

  describe "GET /api/v1/admin/outreel/prospects" do
    it "401s without a token" do
      get "/api/v1/admin/outreel/prospects"
      expect(response).to have_http_status(:unauthorized)
    end

    it "lists prospects newest first" do
      create(:prospect, email: "alice@example.com")
      create(:prospect, email: "bob@example.com")

      get "/api/v1/admin/outreel/prospects", headers: auth_header

      expect(response).to have_http_status(:ok)
      emails = response.parsed_body.map { |p| p["email"] }
      expect(emails).to contain_exactly("alice@example.com", "bob@example.com")
    end

    it "filters by q across email and name fields" do
      create(:prospect, email: "alice@acme.com",  first_name: "Alice", company_name: "Acme")
      create(:prospect, email: "bob@example.com", first_name: "Bob",   company_name: "Example")

      get "/api/v1/admin/outreel/prospects", params: { q: "acme" }, headers: auth_header
      emails = response.parsed_body.map { |p| p["email"] }
      expect(emails).to eq(%w[alice@acme.com])
    end
  end

  describe "POST /api/v1/admin/outreel/prospects" do
    it "creates a prospect and logs activity" do
      payload = { prospect: { email: "new@example.com", first_name: "New", last_name: "Lead" } }

      expect {
        post "/api/v1/admin/outreel/prospects", params: payload.to_json, headers: auth_header
      }.to change { Prospect.count }.by(1)
       .and change { Activity.count }.by(1)

      expect(response).to have_http_status(:created)
      expect(Activity.last.event_type).to eq("prospect_created")
    end

    it "422s on duplicate email" do
      create(:prospect, email: "dup@example.com")

      post "/api/v1/admin/outreel/prospects",
        params: { prospect: { email: "dup@example.com" } }.to_json,
        headers: auth_header

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/admin/outreel/prospects/:id" do
    it "returns full detail including activities and latest video" do
      p = create(:prospect)
      v = create(:video, prospect: p, status: "ready")

      get "/api/v1/admin/outreel/prospects/#{p.id}", headers: auth_header

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["email"]).to eq(p.email)
      expect(body.dig("active_video", "id")).to eq(v.id)
      expect(body["activities"]).to be_an(Array)
      expect(body).to include("view_count" => 0, "last_viewed_at" => nil)
    end

    it "reports view_count + last_viewed_at from logged activities" do
      p = create(:prospect)
      Activity.log!(p, "video_viewed", { slug: "aaa", ip_hash: "h1" })
      latest = Activity.log!(p, "video_viewed", { slug: "aaa", ip_hash: "h2" })

      get "/api/v1/admin/outreel/prospects/#{p.id}", headers: auth_header

      expect(response.parsed_body["view_count"]).to eq(2)
      expect(response.parsed_body["last_viewed_at"]).to eq(latest.occurred_at.iso8601)
    end

    it "view stats appear on the index too" do
      p = create(:prospect, email: "watcher@example.com")
      Activity.log!(p, "video_viewed", { slug: "x" })

      get "/api/v1/admin/outreel/prospects", headers: auth_header

      row = response.parsed_body.find { |r| r["email"] == "watcher@example.com" }
      expect(row["view_count"]).to eq(1)
      expect(row["last_viewed_at"]).to be_present
    end
  end

  describe "DELETE /api/v1/admin/outreel/prospects/:id" do
    it "destroys the prospect and cascades to videos/activities" do
      p = create(:prospect)
      create(:video, prospect: p)
      Activity.log!(p, "prospect_created")

      expect {
        delete "/api/v1/admin/outreel/prospects/#{p.id}", headers: auth_header
      }.to change { Prospect.count }.by(-1)
       .and change { Video.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "lead-magnet vs prospect isolation" do
    it "lead_magnet_requests and prospects with the same email are independent" do
      magnet = create(:lead_magnet)
      create(:lead_magnet_request, lead_magnet: magnet, email: "same@example.com")
      create(:prospect, email: "same@example.com")

      get "/api/v1/admin/outreel/prospects", headers: auth_header
      prospect_emails = response.parsed_body.map { |p| p["email"] }
      expect(prospect_emails).to eq(%w[same@example.com])

      get "/api/v1/admin/leads", headers: auth_header
      lead_emails = response.parsed_body["data"].map { |l| l["email"] }
      expect(lead_emails).to eq(%w[same@example.com])

      # Crucially: no JSON field crosses over between the two responses.
      expect(response.parsed_body["data"].first).not_to have_key("first_name")
    end
  end
end
