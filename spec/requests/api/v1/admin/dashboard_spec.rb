require "rails_helper"

RSpec.describe "GET /api/v1/admin/dashboard", type: :request do
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

  it "401s without a token" do
    get "/api/v1/admin/dashboard"
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns zero counts and empty lists when the database is empty" do
    get "/api/v1/admin/dashboard", headers: auth_header

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["lead_funnel"]).to include(
      "assessments_total" => 0,
      "leads_total"       => 0,
      "magnet_requests_total" => 0,
    )
    expect(body["outreach_pipeline"]).to include(
      "prospects_total" => 0,
      "videos_in_flight" => 0,
    )
    expect(body["recent_assessments"]).to eq([])
    expect(body["recent_magnet_requests"]).to eq([])
    expect(body["recent_activity"]).to eq([])
  end

  it "surfaces seeded data in the right buckets" do
    magnet   = create(:lead_magnet, slug: "playbook", title: "Playbook")
    create(:lead_magnet_request, lead_magnet: magnet, email: "alice@example.com",
                                  verified_at: 1.hour.ago)
    create(:assessment, email: "alice@example.com", archetype: "wishful_thinker", total_score: 30)

    prospect = create(:prospect, email: "alice@acme.com")
    create(:video, prospect: prospect, status: "ready")
    Activity.log!(prospect, "video_ready", { slug: "abcd1234" })

    sl_id    = 999_001
    create(:smartlead_campaign, smartlead_id: sl_id)
    CampaignPush.create!(prospect: prospect, smartlead_campaign_id: sl_id, status: "success", pushed_at: Time.current)

    get "/api/v1/admin/dashboard", headers: auth_header

    expect(response).to have_http_status(:ok)
    body = response.parsed_body

    expect(body.dig("lead_funnel", "assessments_total")).to eq(1)
    expect(body.dig("lead_funnel", "assessments_by_archetype")).to eq("wishful_thinker" => 1)
    expect(body.dig("lead_funnel", "leads_total")).to eq(1)
    expect(body.dig("lead_funnel", "magnet_requests_verified")).to eq(1)

    expect(body.dig("outreach_pipeline", "prospects_total")).to eq(1)
    expect(body.dig("outreach_pipeline", "prospects_by_status")).to eq("not_contacted" => 1)
    expect(body.dig("outreach_pipeline", "videos_ready")).to eq(1)

    expect(body.dig("smartlead_activity", "pushes_this_week")).to eq(1)
    expect(body.dig("smartlead_activity", "pushes_by_status")).to eq("success" => 1)
    expect(body.dig("smartlead_activity", "campaigns_synced_total")).to eq(1)

    expect(body["recent_assessments"].first).to include("email" => "alice@example.com", "archetype" => "wishful_thinker")
    expect(body["recent_magnet_requests"].first.dig("magnet", "slug")).to eq("playbook")
    expect(body["recent_activity"].first).to include("event_type" => "video_ready")
  end
end
