# Generate a JWT for hitting the admin endpoints without going through the
# login flow — handy for scripts and smoke testing.
#
#   docker compose run --rm web bin/rails admin:token
#   docker compose run --rm web bin/rails admin:token EXPIRES_IN_DAYS=30 EMAIL=bilal@lumelogics.com

namespace :admin do
  desc "Print a JWT for the admin endpoints (default 365-day expiry)."
  task token: :environment do
    days  = ENV.fetch("EXPIRES_IN_DAYS", "365").to_i
    admin = ENV["EMAIL"].present? ? AdminUser.find_by!(email: ENV["EMAIL"].downcase.strip) : nil

    token, exp = AdminJwt.encode(admin, expires_in: days.days)

    puts token
    puts "Expires: #{Time.at(exp)} (#{days} days)"
    puts "Bound to: #{admin&.email || '(no admin user — legacy token)'}"
  end
end
