# JWT-based auth for admin endpoints. Tokens are issued out-of-band (see
# lib/tasks/admin_token.rake) and presented as `Authorization: Bearer <jwt>`.

module AdminAuthentication
  extend ActiveSupport::Concern

  ALGORITHM = "HS256".freeze

  included do
    before_action :authenticate_admin!
  end

  private

  def authenticate_admin!
    header = request.headers["Authorization"].to_s
    token  = header.start_with?("Bearer ") ? header.delete_prefix("Bearer ").strip : nil

    if token.blank?
      render json: { error: "missing_authorization" }, status: :unauthorized
      return
    end

    JWT.decode(token, jwt_secret, true, algorithm: ALGORITHM)
  rescue JWT::ExpiredSignature
    render json: { error: "token_expired" }, status: :unauthorized
  rescue JWT::DecodeError, JWT::VerificationError
    render json: { error: "invalid_token" }, status: :unauthorized
  end

  def jwt_secret
    secret = ENV["ADMIN_JWT_SECRET"]
    raise "ADMIN_JWT_SECRET is not set" if secret.blank?

    secret
  end
end
