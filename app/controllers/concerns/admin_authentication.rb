# JWT-based auth for admin endpoints. Tokens are issued by the sessions
# controller (POST /api/v1/admin/sessions) or out-of-band via the
# `bin/rails admin:token` task. Both go through AdminJwt.

module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!
    attr_reader :current_admin_user
  end

  private

  def authenticate_admin!
    header = request.headers["Authorization"].to_s
    token  = header.start_with?("Bearer ") ? header.delete_prefix("Bearer ").strip : nil

    if token.blank?
      render json: { error: "missing_authorization" }, status: :unauthorized
      return
    end

    payload             = AdminJwt.decode(token)
    @current_admin_user = AdminUser.find_by(id: payload["sub"]) if payload["sub"].present?
  rescue JWT::ExpiredSignature
    render json: { error: "token_expired" }, status: :unauthorized
  rescue JWT::DecodeError, JWT::VerificationError
    render json: { error: "invalid_token" }, status: :unauthorized
  end
end
