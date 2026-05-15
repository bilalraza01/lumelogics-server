# Sends the lead-magnet verification email via Resend. Mirrors
# AssessmentEmailSender exactly, including the gem-1.3 quirk of passing a
# single positional hash (kwargs raise ArgumentError in Ruby 3).
#
# When RESEND_API_KEY is unset, log the rendered access URL to stdout so
# the flow stays demoable in local dev without a real key.

class LeadMagnetEmailSender
  def initialize(request)
    @request = request
    @magnet  = request.lead_magnet
  end

  def call
    if Resend.api_key.to_s.strip.empty?
      log_preview
    else
      Resend::Emails.send({
        from:    ENV.fetch("MAIL_FROM", "Lumelogics <onboarding@resend.dev>"),
        to:      [@request.email],
        subject: @magnet.email_subject,
        html:    html_body,
      })
    end

    @request.update!(email_sent: true, email_sent_at: Time.current)
  end

  private

  def access_url
    base = ENV.fetch("FRONTEND_URL", "https://lumelogics.com")
    "#{base}/free/#{@magnet.slug}/access/#{@request.verification_token}"
  end

  def html_body
    LeadMagnetMailerView.new(@request, access_url).render
  end

  def log_preview
    Rails.logger.info(
      "[LeadMagnetEmailSender] RESEND_API_KEY unset — would have sent " \
      "magnet email to #{@request.email} for '#{@magnet.slug}' " \
      "(access_url=#{access_url}). Set RESEND_API_KEY in .env to enable real delivery.",
    )
  end
end
