# Sends the Fintagic contact-form notification email via Resend. Mirrors
# LeadMagnetEmailSender exactly, including the gem-1.3 quirk of passing a
# single positional hash (kwargs raise ArgumentError in Ruby 3).
#
# Recipient is hardcoded — this endpoint only ever notifies Bilal. If that
# needs to change (staging inbox, forwarding elsewhere), swap RECIPIENT for
# an ENV.fetch.
#
# When RESEND_API_KEY is unset, log a preview to stdout so local dev works
# without a real key.

class FintagicContactEmailSender
  RECIPIENT = "bilal@lumelogics.com".freeze

  def initialize(submission)
    @submission = submission
  end

  def call
    if Resend.api_key.to_s.strip.empty?
      log_preview
    else
      Resend::Emails.send({
        from:     ENV.fetch("MAIL_FROM", "Fintagic <onboarding@resend.dev>"),
        to:       [RECIPIENT],
        reply_to: [@submission.email],
        subject:  subject,
        html:     html_body,
      })
    end

    @submission.update!(email_sent: true, email_sent_at: Time.current)
  end

  private

  def subject
    "New Fintagic inquiry — #{@submission.company}"
  end

  def html_body
    rows = [
      ["Name",           @submission.name],
      ["Email",          @submission.email],
      ["Brand / company", @submission.company],
      ["Website",        @submission.website.presence || "—"],
      ["Monthly revenue", @submission.revenue],
      ["Message",        simple_format(@submission.message)],
      ["Submitted",      @submission.created_at.iso8601],
      ["IP",             @submission.ip_address.presence || "—"],
      ["User agent",     @submission.user_agent.presence || "—"],
    ]

    dl_items = rows.map { |label, value|
      "<dt style=\"font-weight:600;color:#043D45;margin-top:12px\">#{ERB::Util.html_escape(label)}</dt>" \
        "<dd style=\"margin:2px 0 0;color:#011418\">#{value}</dd>"
    }.join

    <<~HTML
      <div style="font-family:system-ui,-apple-system,sans-serif;max-width:560px;margin:0 auto;padding:24px;color:#011418">
        <h1 style="font-size:20px;margin:0 0 4px">New Fintagic inquiry</h1>
        <p style="color:#043D45;margin:0 0 20px;font-size:14px">
          Reply-to is set to the submitter — hit reply to respond directly.
        </p>
        <dl style="margin:0">#{dl_items}</dl>
      </div>
    HTML
  end

  # Minimal <br> conversion so the message reads naturally in the email.
  def simple_format(text)
    ERB::Util.html_escape(text.to_s).gsub("\n", "<br>")
  end

  def log_preview
    Rails.logger.info(
      "[FintagicContactEmailSender] RESEND_API_KEY unset — would have sent " \
      "contact notification to #{RECIPIENT} for #{@submission.email} " \
      "(company=#{@submission.company.inspect}). " \
      "Set RESEND_API_KEY in .env to enable real delivery.",
    )
  end
end
