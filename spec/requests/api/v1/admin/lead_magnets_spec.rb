require "rails_helper"

RSpec.describe "Api::V1::Admin::LeadMagnets", type: :request do
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

  describe "GET /api/v1/admin/lead-magnets" do
    it "401s without a token" do
      get "/api/v1/admin/lead-magnets"
      expect(response).to have_http_status(:unauthorized)
    end

    it "lists magnets with pagination + request_count" do
      magnets = create_list(:lead_magnet, 2)
      create(:lead_magnet_request, lead_magnet: magnets.first)

      get "/api/v1/admin/lead-magnets", headers: auth_header

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].length).to eq(2)
      expect(body["pagination"]).to include("page" => 1, "per_page" => 50, "total" => 2)
      expect(body["data"].first.keys).to include(
        "id", "slug", "title", "resource_type", "request_count", "updated_at",
      )
    end
  end

  describe "GET /api/v1/admin/lead-magnets/:id" do
    it "returns a single magnet" do
      magnet = create(:lead_magnet, slug: "playbook", title: "Playbook")
      get "/api/v1/admin/lead-magnets/#{magnet.id}", headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("slug" => "playbook", "title" => "Playbook")
    end

    it "404s for an unknown id" do
      get "/api/v1/admin/lead-magnets/#{SecureRandom.uuid}", headers: auth_header
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/admin/lead-magnets" do
    let(:valid_attrs) do
      {
        slug:          "new-checklist",
        title:         "New Checklist",
        description:   "A handy checklist.",
        resource_type: "pdf",
        resource_url:  "/lead-magnets/new-checklist.pdf",
        email_subject: "Your checklist",
        email_intro:   "Click below.",
        vsl_headline:  "Use it like this",
      }
    end

    it "creates a magnet" do
      expect {
        post "/api/v1/admin/lead-magnets",
          params: valid_attrs.to_json, headers: auth_header
      }.to change { LeadMagnet.count }.by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["slug"]).to eq("new-checklist")
    end

    it "422s when slug is duplicate" do
      create(:lead_magnet, slug: "new-checklist")

      post "/api/v1/admin/lead-magnets",
        params: valid_attrs.to_json, headers: auth_header

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to have_key("slug")
    end

    it "422s when required fields missing" do
      post "/api/v1/admin/lead-magnets",
        params: { slug: "x" }.to_json, headers: auth_header

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/admin/lead-magnets/:id" do
    it "updates a magnet" do
      magnet = create(:lead_magnet, title: "Old title")

      patch "/api/v1/admin/lead-magnets/#{magnet.id}",
        params: { title: "New title" }.to_json, headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(magnet.reload.title).to eq("New title")
    end

    it "422s on invalid update" do
      magnet = create(:lead_magnet)

      patch "/api/v1/admin/lead-magnets/#{magnet.id}",
        params: { slug: "" }.to_json, headers: auth_header

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/admin/lead-magnets/:id" do
    it "deletes a magnet and its requests" do
      magnet = create(:lead_magnet)
      create(:lead_magnet_request, lead_magnet: magnet)

      expect {
        delete "/api/v1/admin/lead-magnets/#{magnet.id}", headers: auth_header
      }.to change { LeadMagnet.count }.by(-1)
       .and change { LeadMagnetRequest.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
