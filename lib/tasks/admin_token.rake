# Generate a JWT for hitting the admin endpoints.
#
#   docker compose run --rm web bin/rails admin:token
#   docker compose run --rm web bin/rails admin:token EXPIRES_IN_DAYS=30
#
# Store the printed token somewhere safe (1Password) — there's no admin login
# flow for v1.

namespace :admin do
  desc "Print a JWT valid for ADMIN_JWT_SECRET (default 1-year expiry)"
  task token: :environment do
    require "jwt"

    secret = ENV["ADMIN_JWT_SECRET"]
    if secret.to_s.strip.empty?
      abort "ADMIN_JWT_SECRET is not set."
    end

    days = ENV.fetch("EXPIRES_IN_DAYS", "365").to_i
    payload = { admin: true, iat: Time.now.to_i, exp: (Time.now + days.days).to_i }
    token = JWT.encode(payload, secret, "HS256")

    puts token
    puts "Expires: #{Time.at(payload[:exp])} (#{days} days)"
  end
end
