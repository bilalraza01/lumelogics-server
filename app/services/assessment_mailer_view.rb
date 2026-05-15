# Plain Ruby class that returns an HTML string for the results email.
# We don't use ActionMailer because the email is the only one we send and
# Resend takes an HTML body directly.

class AssessmentMailerView
  def initialize(assessment, results_url)
    @assessment  = assessment
    @results_url = results_url
  end

  def render
    meta = ArchetypeMeta.for(@assessment.archetype)

    <<~HTML
      <!DOCTYPE html>
      <html>
        <body style="margin:0;padding:0;background:#f4f3ee;font-family:'Inter','Helvetica Neue',Arial,sans-serif;color:#14131a;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#f4f3ee;">
            <tr>
              <td align="center">
                <table role="presentation" width="560" cellpadding="0" cellspacing="0" border="0" style="max-width:560px;margin:0 auto;">
                  <tr>
                    <td style="padding:32px 24px 16px;">
                      <div style="font-weight:700;letter-spacing:0.04em;color:#7c3aed;font-size:14px;">LUMELOGICS</div>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:0 24px;">
                      <h1 style="margin:0 0 8px;font-size:24px;line-height:1.2;color:#14131a;">Your AI Readiness Score</h1>
                      <p style="margin:0 0 24px;font-size:14px;color:#6b6a78;">
                        Here's how your business scored across the four dimensions of AI readiness.
                      </p>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:0 24px 24px;">
                      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:linear-gradient(135deg,#6926d6,#2a0f5c);border-radius:12px;">
                        <tr>
                          <td style="padding:28px;color:#ffffff;">
                            <div style="font-size:11px;letter-spacing:1.5px;text-transform:uppercase;opacity:0.75;margin-bottom:8px;">
                              Your archetype
                            </div>
                            <div style="font-size:22px;font-weight:700;margin-bottom:8px;">
                              #{ERB::Util.html_escape(meta[:display])}
                            </div>
                            <div style="font-size:42px;font-weight:800;line-height:1;">
                              #{@assessment.total_score} / 100
                            </div>
                          </td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:0 24px 24px;">
                      <p style="margin:0;font-size:14px;line-height:1.6;color:#14131a;">
                        #{ERB::Util.html_escape(meta[:verdict])}
                      </p>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:0 24px 32px;">
                      <a href="#{ERB::Util.html_escape(@results_url)}"
                         style="display:inline-block;background:#7c3aed;color:#ffffff;padding:14px 22px;border-radius:8px;text-decoration:none;font-weight:600;font-size:15px;">
                        View your full results
                      </a>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:0 24px 24px;">
                      <hr style="border:none;border-top:1px solid #e4e2dc;margin:0 0 16px;">
                      <p style="margin:0;font-size:12px;color:#9b9aa6;line-height:1.6;">
                        Lumelogics &middot; AI workflow automation<br>
                        <a href="https://lumelogics.com" style="color:#7c3aed;text-decoration:none;">lumelogics.com</a>
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
      </html>
    HTML
  end
end
