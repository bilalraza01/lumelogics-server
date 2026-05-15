require "rails_helper"

RSpec.describe "POST /api/v1/lead-magnets/:slug/requests", type: :request do
  let!(:magnet) { create(:lead_magnet, slug: "test-magnet") }

  it "creates a request, enqueues the email job, returns 201" do
    expect {
      post "/api/v1/lead-magnets/test-magnet/requests",
        params: { email: "prospect@example.com" },
        as: :json
    }.to change(LeadMagnetRequest, :count).by(1)
      .and have_enqueued_job(LeadMagnetEmailJob)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body["status"]).to eq("email_sent")

    lmr = LeadMagnetRequest.last
    expect(lmr.email).to eq("prospect@example.com")
    expect(lmr.lead_magnet).to eq(magnet)
    expect(lmr.verification_token).to be_present
  end

  it "returns 404 when slug doesn't exist" do
    post "/api/v1/lead-magnets/nope/requests",
      params: { email: "prospect@example.com" },
      as: :json
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body["error"]).to eq("magnet_not_found")
  end

  it "returns 422 on invalid email" do
    post "/api/v1/lead-magnets/test-magnet/requests",
      params: { email: "not-an-email" },
      as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body["error"]).to eq("invalid_email")
  end

  it "deduplicates within 1 hour — returns existing record, no new enqueue" do
    post "/api/v1/lead-magnets/test-magnet/requests",
      params: { email: "dup@example.com" },
      as: :json
    first_token = LeadMagnetRequest.last.verification_token

    expect {
      post "/api/v1/lead-magnets/test-magnet/requests",
        params: { email: "dup@example.com" },
        as: :json
    }.not_to change(LeadMagnetRequest, :count)

    expect(response).to have_http_status(:ok)
    expect(LeadMagnetRequest.last.verification_token).to eq(first_token)
  end
end

RSpec.describe "GET /api/v1/lead-magnets/:slug/access/:token", type: :request do
  let!(:magnet) { create(:lead_magnet, slug: "test-magnet", title: "Test Magnet") }
  let!(:lmr)    { create(:lead_magnet_request, lead_magnet: magnet) }

  it "returns the magnet payload and stamps verified_at for a valid token" do
    expect {
      get "/api/v1/lead-magnets/test-magnet/access/#{lmr.verification_token}"
    }.to change { lmr.reload.verified_at }.from(nil)

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["slug"]).to eq("test-magnet")
    expect(body["title"]).to eq("Test Magnet")
    # pdf is a downloadable type → resource.url points at the token-gated
    # download endpoint (not the raw resource_url) and download is true.
    expect(body["resource"]).to include("type" => "pdf", "download" => true)
    expect(body["resource"]["url"]).to end_with(
      "/api/v1/lead-magnets/test-magnet/download/#{lmr.verification_token}",
    )
    expect(body["calendly_url"]).to be_present
    expect(body["verified_at"]).to be_present
  end

  it "returns the raw URL and download:false for a google_doc magnet" do
    doc = create(:lead_magnet, slug: "doc-magnet", title: "Doc",
                               resource_type: "google_doc",
                               resource_url: "https://docs.google.com/document/d/abc/edit")
    req = create(:lead_magnet_request, lead_magnet: doc)

    get "/api/v1/lead-magnets/doc-magnet/access/#{req.verification_token}"

    expect(response.parsed_body["resource"]).to eq(
      "type" => "google_doc",
      "url" => "https://docs.google.com/document/d/abc/edit",
      "download" => false,
    )
  end

  describe "GET /api/v1/lead-magnets/:slug/download/:token" do
    it "streams a legacy resource_url magnet via redirect" do
      get "/api/v1/lead-magnets/test-magnet/download/#{lmr.verification_token}"
      # No uploaded file, legacy resource_url → redirect to it.
      expect(response).to have_http_status(:redirect)
      expect(response.headers["Location"]).to end_with("/lead-magnets/test.pdf")
    end

    it "404s for an unknown token" do
      get "/api/v1/lead-magnets/test-magnet/download/nope"
      expect(response).to have_http_status(:not_found)
    end

    it "422s for a non-downloadable (google_doc) magnet" do
      doc = create(:lead_magnet, slug: "doc2", resource_type: "google_doc",
                                 resource_url: "https://docs.google.com/x")
      req = create(:lead_magnet_request, lead_magnet: doc)
      get "/api/v1/lead-magnets/doc2/download/#{req.verification_token}"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  it "does not re-stamp verified_at on repeat access" do
    get "/api/v1/lead-magnets/test-magnet/access/#{lmr.verification_token}"
    first_verified = lmr.reload.verified_at
    expect(first_verified).to be_present

    get "/api/v1/lead-magnets/test-magnet/access/#{lmr.verification_token}"
    expect(lmr.reload.verified_at).to eq(first_verified)
  end

  it "returns 404 for an unknown token" do
    get "/api/v1/lead-magnets/test-magnet/access/bogus"
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body["error"]).to eq("not_found")
  end

  it "returns 404 for an unknown slug" do
    get "/api/v1/lead-magnets/does-not-exist/access/#{lmr.verification_token}"
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body["error"]).to eq("magnet_not_found")
  end
end
