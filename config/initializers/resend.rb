# Resend SDK setup. The API key is optional — when unset, AssessmentEmailSender
# logs the rendered HTML to stdout instead of attempting a real send.

require "resend"

api_key = ENV["RESEND_API_KEY"].to_s.strip
Resend.api_key = api_key unless api_key.empty?
