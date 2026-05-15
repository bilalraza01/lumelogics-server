# Plain Ruby class that returns the verification-email HTML. We keep this
# under app/services/ — NOT app/views/ — because Zeitwerk doesn't autoload
# the views directory.

class LeadMagnetMailerView
  def initialize(request, access_url)
    @request    = request
    @magnet     = request.lead_magnet
    @access_url = access_url
  end

  def render
    intro = @magnet.email_intro.presence || default_intro

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
                      <h1 style="margin:0 0 8px;font-size:24px;line-height:1.2;color:#14131a;">
                        Your link to #{ERB::Util.html_escape(@magnet.title)}
                      </h1>
                      <p style="margin:0 0 24px;font-size:15px;line-height:1.6;color:#14131a;">
                        #{ERB::Util.html_escape(intro)}
                      </p>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:0 24px 24px;">
                      <a href="#{ERB::Util.html_escape(@access_url)}"
                         style="display:inline-block;background:#7c3aed;color:#ffffff;padding:14px 22px;border-radius:8px;text-decoration:none;font-weight:600;font-size:15px;">
                        Get the resource
                      </a>
                    </td>
                  </tr>
                  <tr>
                    <td style="padding:0 24px 16px;">
                      <p style="margin:0;font-size:13px;color:#6b6a78;line-height:1.6;">
                        If the button doesn't work, paste this link in your browser:<br>
                        <span style="color:#7c3aed;word-break:break-all;">#{ERB::Util.html_escape(@access_url)}</span>
                      </p>
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

  private

  def default_intro
    "Click the button below to access #{@magnet.title}. The link is just for you, feel free to keep it bookmarked."
  end
end
