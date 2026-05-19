# Regenerate the public sample audit (/audit/demo) from the current
# Scaleforte content. The seed is create-only, so editing Scaleforte does
# not refresh the demo automatically — run this to rebuild it.
#
#   docker compose -f docker-compose.prod.yml exec web bin/rails audits:refresh_demo
#   bin/rails audits:refresh_demo   (dev)

namespace :audits do
  desc "Rebuild the public /audit/demo sample from the current Scaleforte content."
  task refresh_demo: :environment do
    require Rails.root.join("db/seeds/audits/demo")

    Audit.where(slug: "demo").destroy_all

    Audit.create!(
      slug:         "demo",
      client_name:  "Northpeak Commerce",
      industry:     "Amazon Agency (PPC & Catalogue Optimization)",
      status:       "delivered",
      started_on:   Date.new(2026, 4, 7),
      completed_on: Date.new(2026, 5, 12),
      content:      Seeds::Audits::Demo.content,
    )

    puts "✓ Rebuilt /audit/demo from current Scaleforte content"
  end
end
