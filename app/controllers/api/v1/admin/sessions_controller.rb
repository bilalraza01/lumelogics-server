module Api
  module V1
    module Admin
      class SessionsController < ApplicationController
        # POST /api/v1/admin/sessions
        # body: { email, password }
        # 200 -> { token, expires_at, admin: { id, email } }
        # 401 -> { error: "invalid_credentials" }
        # 422 -> { error: "missing_credentials" }
        def create
          email    = params[:email].to_s.downcase.strip
          password = params[:password].to_s

          if email.blank? || password.blank?
            render json: { error: "missing_credentials" }, status: :unprocessable_entity
            return
          end

          admin = AdminUser.find_by(email: email)

          if admin&.authenticate(password)
            token, exp = AdminJwt.encode(admin)
            render json: {
              token:      token,
              expires_at: Time.at(exp).iso8601,
              admin:      { id: admin.id, email: admin.email },
            }
          else
            render json: { error: "invalid_credentials" }, status: :unauthorized
          end
        end
      end
    end
  end
end
