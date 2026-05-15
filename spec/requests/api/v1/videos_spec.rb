require "rails_helper"

RSpec.describe "GET /api/v1/videos/by-slug/:slug", type: :request do
  let(:prospect) { create(:prospect, status: "sent") }
  let(:video) do
    create(:video, prospect: prospect, status: "ready",
                   mp4_url: "https://cdn/example.mp4",
                   gif_url: "https://cdn/example.gif")
  end

  it "404s for an unknown slug" do
    get "/api/v1/videos/by-slug/zzzzzzzz"
    expect(response).to have_http_status(:not_found)
  end

  it "404s when the video isn't ready yet" do
    pending_video = create(:video, prospect: prospect, status: "pending")
    get "/api/v1/videos/by-slug/#{pending_video.slug}"
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body["error"]).to eq("not_ready")
  end

  it "returns the player payload for a ready video" do
    get "/api/v1/videos/by-slug/#{video.slug}"

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body).to include(
      "slug"    => video.slug,
      "mp4_url" => video.mp4_url,
      "gif_url" => video.gif_url,
    )
  end

  describe "view recording" do
    it "logs a video_viewed activity on first hit" do
      expect {
        get "/api/v1/videos/by-slug/#{video.slug}"
      }.to change { prospect.activities.where(event_type: "video_viewed").count }.by(1)
    end

    it "promotes status sent → viewed on first view and logs status_changed" do
      get "/api/v1/videos/by-slug/#{video.slug}"
      prospect.reload

      expect(prospect.status).to eq("viewed")
      change_event = prospect.activities.where(event_type: "status_changed").last
      expect(change_event.metadata).to include("from" => "sent", "to" => "viewed", "trigger" => "video_view")
    end

    it "promotes not_contacted → viewed too" do
      prospect.update!(status: "not_contacted")
      get "/api/v1/videos/by-slug/#{video.slug}"
      expect(prospect.reload.status).to eq("viewed")
    end

    it "does NOT walk replied / call_booked / won backward to viewed" do
      %w[replied call_booked won lost].each do |downstream_status|
        p2 = create(:prospect, status: downstream_status)
        v2 = create(:video, prospect: p2, status: "ready")

        get "/api/v1/videos/by-slug/#{v2.slug}"

        expect(p2.reload.status).to eq(downstream_status)
      end
    end

    it "doesn't double-count views from the same IP within the dedup window" do
      get "/api/v1/videos/by-slug/#{video.slug}"
      get "/api/v1/videos/by-slug/#{video.slug}"
      expect(prospect.activities.where(event_type: "video_viewed").count).to eq(1)
    end
  end
end
