# Cross-origin access for the Lumelogics frontend. ALLOWED_ORIGINS is a
# comma-separated env var (see .env.example).

allowed = ENV.fetch("ALLOWED_ORIGINS", "").split(",").map(&:strip).reject(&:empty?)

if allowed.any?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins(*allowed)
      resource "/api/*",
        headers: :any,
        methods: %i[get post patch put delete options],
        expose: %w[Content-Type]

      # New /v1/* prefix (see routes.rb). Fintagic contact form + any
      # future endpoints migrated off the /api/v1/... path get CORS from here.
      resource "/v1/*",
        headers: :any,
        methods: %i[get post patch put delete options],
        expose: %w[Content-Type]
    end
  end
end
