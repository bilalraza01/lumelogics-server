require "jwt"

# Central encode/decode for admin JWTs. Used by the sessions controller (login),
# the AdminAuthentication concern (request gating), and the admin:token rake
# task. Tokens carry the admin user's id in `sub`; older "headless" tokens
# without a sub still verify — current_admin_user just returns nil for those.
class AdminJwt
  ALGORITHM      = "HS256".freeze
  DEFAULT_EXPIRY = 7.days

  def self.encode(admin_user, expires_in: DEFAULT_EXPIRY)
    now     = Time.now.to_i
    payload = {
      admin: true,
      sub:   admin_user&.id,
      iat:   now,
      exp:   (Time.now + expires_in).to_i,
    }
    [JWT.encode(payload, secret, ALGORITHM), payload[:exp]]
  end

  def self.decode(token)
    JWT.decode(token, secret, true, algorithm: ALGORITHM).first
  end

  def self.secret
    value = ENV["ADMIN_JWT_SECRET"]
    raise "ADMIN_JWT_SECRET is not set" if value.to_s.strip.empty?

    value
  end
end
