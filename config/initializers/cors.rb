# Cross-origin access for the Lumelogics frontend. ALLOWED_ORIGINS is a
# comma-separated env var (see .env.example).

allowed = ENV.fetch("ALLOWED_ORIGINS", "").split(",").map(&:strip).reject(&:empty?)

if allowed.any?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins(*allowed)
      resource "/api/*",
        headers: :any,
        methods: %i[get post options],
        expose: %w[Content-Type]
    end
  end
end
