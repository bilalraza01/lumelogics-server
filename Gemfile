source "https://rubygems.org"

gem "rails", "~> 7.2.3", ">= 7.2.3.1"

# Database
gem "pg", "~> 1.5"

# Web server
gem "puma", ">= 5.0"

# CORS for the Lumelogics frontend
gem "rack-cors"

# JWT for admin endpoints
gem "jwt"

# Transactional email
gem "resend"

# Background jobs (PostgreSQL-backed — no Redis needed)
gem "good_job", "~> 4.0"

# Standard niceties
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false

# Environment variables via .env in dev/test
gem "dotenv-rails", groups: %i[development test]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  # Testing
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails"
end
