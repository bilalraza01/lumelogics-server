require "rails_helper"

RSpec.describe "Api::V1::Admin::Audits", type: :request do
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

  def valid_content
    {
      schema_version: 1,
      hero: {}, ai_moment: {}, journey: {}, prototype: {}, footer: {},
      process_map: {}, report: {},
      findings: { pain_points: [], optimisations: [] },
      waste: { opportunities: [] },
      blueprint: { opportunities: [] },
      sessions: [], deliverables: [], downloads: [], categories: [],
    }
  end

  describe "GET /api/v1/admin/audits" do
    it "401s without a token" do
      get "/api/v1/admin/audits"
      expect(response).to have_http_status(:unauthorized)
    end

    it "lists audits with pagination, metadata only (no content)" do
      create_list(:audit, 2)

      get "/api/v1/admin/audits", headers: auth_header

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].length).to eq(2)
      expect(body["pagination"]).to include("page" => 1, "per_page" => 50, "total" => 2)
      expect(body["data"].first.keys).to include(
        "id", "slug", "client_name", "status", "updated_at",
      )
      expect(body["data"].first).not_to have_key("content")
    end
  end

  describe "GET /api/v1/admin/audits/:id" do
    it "returns a single audit with its content" do
      audit = create(:audit, slug: "acme", client_name: "Acme")
      get "/api/v1/admin/audits/#{audit.id}", headers: auth_header

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to include("slug" => "acme", "client_name" => "Acme")
      expect(body["content"]).to include("schema_version" => 1)
    end

    it "404s for an unknown id" do
      get "/api/v1/admin/audits/999999", headers: auth_header
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/admin/audits" do
    it "creates an audit and round-trips content" do
      expect {
        post "/api/v1/admin/audits",
          params: { audit: { slug: "newco", client_name: "New Co",
                             status: "in_progress", content: valid_content } }.to_json,
          headers: auth_header
      }.to change { Audit.count }.by(1)

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["slug"]).to eq("newco")
      expect(body["content"]).to include("schema_version" => 1)
    end

    it "422s on duplicate slug" do
      create(:audit, slug: "dup")

      post "/api/v1/admin/audits",
        params: { audit: { slug: "dup", client_name: "X", status: "delivered",
                           content: valid_content } }.to_json,
        headers: auth_header

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to have_key("slug")
    end

    it "422s when content is structurally broken" do
      post "/api/v1/admin/audits",
        params: { audit: { slug: "broken", client_name: "X", status: "delivered",
                           content: { schema_version: 1 } } }.to_json,
        headers: auth_header

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to have_key("content")
    end
  end

  describe "PATCH /api/v1/admin/audits/:id" do
    it "updates metadata and content" do
      audit = create(:audit, client_name: "Old")

      patch "/api/v1/admin/audits/#{audit.id}",
        params: { audit: { client_name: "New" } }.to_json, headers: auth_header

      expect(response).to have_http_status(:ok)
      expect(audit.reload.client_name).to eq("New")
    end

    it "422s on invalid update" do
      audit = create(:audit)

      patch "/api/v1/admin/audits/#{audit.id}",
        params: { audit: { slug: "" } }.to_json, headers: auth_header

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/admin/audits/:id" do
    it "deletes an audit" do
      audit = create(:audit)

      expect {
        delete "/api/v1/admin/audits/#{audit.id}", headers: auth_header
      }.to change { Audit.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
