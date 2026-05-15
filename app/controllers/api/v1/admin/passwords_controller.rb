module Api
  module V1
    module Admin
      # PATCH /api/v1/admin/password
      # body: { current_password, new_password }
      # 200 -> { status: "updated" }
      # 422 -> { error: "invalid_current_password" } | { error: "missing_fields" }
      #        | { errors: { password: [...] } }
      # 401 -> only for a genuinely unauthenticated request (no/invalid token).
      #
      # A wrong current_password is a 422, NOT a 401 — the session token is
      # still valid, only the supplied field is wrong. The portal auto-logs-out
      # on 401, so a 401 here would wrongly bounce the user to /login.
      #
      # Note: existing JWTs stay valid after a change (the token doesn't encode
      # the password). For a single-admin internal tool that's acceptable: the
      # user stays logged in on this device; new logins use the new password.
      class PasswordsController < ApplicationController
        include AdminAuthentication

        def update
          current = params[:current_password].to_s
          new_pw  = params[:new_password].to_s

          if current.blank? || new_pw.blank?
            return render(json: { error: "missing_fields" }, status: :unprocessable_entity)
          end

          admin = current_admin_user
          return render(json: { error: "invalid_token" }, status: :unauthorized) unless admin

          unless admin.authenticate(current)
            return render(json: { error: "invalid_current_password" }, status: :unprocessable_entity)
          end

          admin.password = new_pw
          if admin.save
            render json: { status: "updated" }
          else
            render json: { errors: admin.errors.as_json }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
