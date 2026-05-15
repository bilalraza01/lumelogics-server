# Sends the results email via Resend, or logs the rendered HTML to stdout
# when RESEND_API_KEY isn't set (so local dev works without a real key).

class AssessmentEmailSender
  def initialize(assessment)
    @assessment = assessment
  end

  def call
    if Resend.api_key.to_s.strip.empty?
      log_preview
    else
      # resend-rb 1.x expects a single positional hash, not keyword args.
      Resend::Emails.send({
        from:    ENV.fetch("MAIL_FROM", "Lumelogics <onboarding@resend.dev>"),
        to:      [@assessment.email],
        subject: "Your AI Readiness Score: #{ArchetypeMeta.for(@assessment.archetype)[:display]}",
        html:    html_body,
      })
    end

    @assessment.update!(email_sent: true, email_sent_at: Time.current)
  end

  private

  def results_url
    base = ENV.fetch("FRONTEND_URL", "https://lumelogics.com")
    "#{base}/free-assessment/results/#{@assessment.result_token}"
  end

  def html_body
    AssessmentMailerView.new(@assessment, results_url).render
  end

  def log_preview
    Rails.logger.info(
      "[AssessmentEmailSender] RESEND_API_KEY unset — would have sent " \
      "result email to #{@assessment.email} (token=#{@assessment.result_token}). " \
      "Set RESEND_API_KEY in .env to enable real delivery.",
    )
  end
end
