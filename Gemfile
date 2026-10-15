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

# Admin password hashing (used by has_secure_password on AdminUser)
gem "bcrypt", "~> 3.1.7"

# Transactional email
gem "resend"

# File uploads for lead-magnet PDFs / files (local disk storage).
gem "carrierwave", "~> 3.0"

# Outreel video pipeline: Cloudflare R2 (S3-compatible) for MP4/GIF storage,
# Faraday for the Smartlead REST API.
gem "aws-sdk-s3", require: false
gem "faraday"

# Background jobs (PostgreSQL-backed — no Redis needed)
gem "good_job", "~> 4.19"

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
