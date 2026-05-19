# Idempotent — run as many times as you want.

# Seed the single admin user from env vars. Skip silently if either var is
# unset (e.g. on CI), since seeds run on every deploy.
if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  admin = AdminUser.find_or_initialize_by(email: ENV["ADMIN_EMAIL"].downcase.strip)
  admin.password = ENV["ADMIN_PASSWORD"]
  if admin.changed?
    admin.save!
    puts "✓ Seeded admin user #{admin.email}"
  end
end

# Adds the AI Readiness Playbook lead magnet referenced from the assessment's
# Wishful Thinker archetype CTA.

LeadMagnet.find_or_create_by!(slug: "ai-readiness-playbook") do |m|
  m.title         = "AI Readiness Playbook"
  m.description   = "A 90-day playbook for operators who want to get their business AI-ready. " \
                    "The workflows to document, the data to track, the people to bring along. " \
                    "Drop your email and we'll send you the link."
  m.resource_type = "pdf"
  # Served from the Next.js frontend's public/ folder.
  m.resource_url  = "/lead-magnets/ai-readiness-playbook.pdf"

  m.email_subject = "Your AI Readiness Playbook"
  m.email_intro   = "Thanks for grabbing the playbook. Click below and we'll open up the resource " \
                    "page where you can download the PDF, watch a short walk-through, and book a call " \
                    "if you'd like a hand applying it."

  m.vsl_headline  = "How to actually use this playbook"
  m.vsl_body      = "In this short video I walk through the three workflows most SMBs should " \
                    "automate first and why most early AI projects fail before they ship. If " \
                    "your business looks like the ones in this playbook, book a free 20-minute " \
                    "call below and we'll talk through where to start."
  # Leave vsl_video_url + calendly_url nil — the model falls back to the
  # default Calendly URL, and the frontend Vsl renders without a video iframe
  # when video_url is blank.
end

puts "✓ Seeded #{LeadMagnet.count} lead magnet(s)"

# Client audit deliverable for Scaleforte (Amazon agency: PPC management +
# catalogue optimization). CREATE-ONLY: the fixture is just the initial
# template. Once the audit exists it is managed through the portal, so
# redeploys / re-seeds must never overwrite portal edits.
require_relative "seeds/audits/scaleforte"

created = false
Audit.find_or_create_by!(slug: "scaleforte") do |a|
  a.client_name  = "Scaleforte"
  a.industry     = "Amazon Agency (PPC & Catalogue Optimization)"
  a.status       = "delivered"
  a.started_on   = Date.new(2026, 4, 7)
  a.completed_on = Date.new(2026, 5, 12)
  a.content      = Seeds::Audits::Scaleforte.content
  created = true
end
puts "✓ Seeded audit /audit/scaleforte" if created

# Public anonymized SAMPLE audit linked from the marketing home page
# (/audit/demo). CREATE-ONLY, same as above.
require_relative "seeds/audits/demo"

demo_created = false
Audit.find_or_create_by!(slug: "demo") do |a|
  a.client_name  = "Northpeak Commerce"
  a.industry     = "Amazon Agency (PPC & Catalogue Optimization)"
  a.status       = "delivered"
  a.started_on   = Date.new(2026, 4, 7)
  a.completed_on = Date.new(2026, 5, 12)
  a.content      = Seeds::Audits::Demo.content
  demo_created = true
end
puts "✓ Seeded audit /audit/demo" if demo_created
