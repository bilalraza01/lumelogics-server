require "rails_helper"

RSpec.describe "PATCH /api/v1/admin/password", type: :request do
  let(:secret) { "test_secret_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
  let(:admin)  { create(:admin_user, password: "original-password") }

  around do |example|
    old = ENV["ADMIN_JWT_SECRET"]
    ENV["ADMIN_JWT_SECRET"] = secret
    example.run
    ENV["ADMIN_JWT_SECRET"] = old
  end

  def auth_header(user = admin)
    token, _ = AdminJwt.encode(user)
    { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
  end

  it "401s without a token" do
    patch "/api/v1/admin/password",
      params: { current_password: "x", new_password: "yyyyyyyy" }.to_json,
      headers: { "Content-Type" => "application/json" }
    expect(response).to have_http_status(:unauthorized)
  end

  it "changes the password with the correct current password" do
    patch "/api/v1/admin/password",
      params: { current_password: "original-password", new_password: "brand-new-password" }.to_json,
      headers: auth_header

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["status"]).to eq("updated")
    expect(admin.reload.authenticate("brand-new-password")).to be_truthy
    expect(admin.authenticate("original-password")).to be_falsey
  end

  it "422s when the current password is wrong (NOT 401 — keeps the session)" do
    patch "/api/v1/admin/password",
      params: { current_password: "WRONG", new_password: "brand-new-password" }.to_json,
      headers: auth_header

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body["error"]).to eq("invalid_current_password")
    expect(admin.reload.authenticate("original-password")).to be_truthy
  end

  it "422s when the new password is too short" do
    patch "/api/v1/admin/password",
      params: { current_password: "original-password", new_password: "short" }.to_json,
      headers: auth_header

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body["errors"]).to have_key("password")
  end

  it "422s when fields are missing" do
    patch "/api/v1/admin/password",
      params: { current_password: "original-password" }.to_json,
      headers: auth_header

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body["error"]).to eq("missing_fields")
  end
end
