# frozen_string_literal: true

# Scaleforte audit deliverable content. Authored as a Ruby fixture so the
# large document stays out of db/seeds.rb. Returns the full structured
# document stored verbatim in audits.content; the web app renders and
# derives all totals from it.
#
# Scaleforte is an Amazon agency: PPC management + catalogue optimization.
# This audits THEIR internal operation (how the agency runs), not a client's.
#
# Number contract: every waste opportunity's annual_cost equals
# weekly_hours * people_affected * hourly_rate * 52 so the web can echo the
# substitution. The web derives all sums/breakdowns; nothing is pre-summed
# here. No em dashes anywhere (entire document is client-facing).
module Seeds
  module Audits
    module Scaleforte
      module_function

      def content
        {
          schema_version: 1,

          hero: {
            eyebrow: "Business Operations Audit",
            client_name: "Scaleforte",
            audit_started_label: "Audit started April 2026",
            status_pill: { label: "Delivered", tone: "success" },
          },

          ai_moment: {
            label: "The AI moment",
            heading: "Most agency work done on a screen will be 40 to 80 percent faster within two years.",
            sub: "This audit is your blueprint for capturing that on your own delivery, not just selling it to clients.",
            analogy_callout: {
              title: "The Excel analogy",
              body: "AI is the spreadsheet skill of this decade. The agencies that fold it into delivery " \
                    "now will run leaner and outbid the ones that do not. The same shift is happening to " \
                    "PPC and catalogue work right now, and it is accelerating.",
            },
            explainer: [
              { icon: "amplify", title: "Amplification, not replacement",
                body: "Your analysts keep judgement and client relationships. AI removes the manual " \
                      "assembly around them so each person covers more accounts well." },
              { icon: "plug", title: "What a connector actually is",
                body: "A secure bridge from your tools (Amazon Ads, Seller Central, Sheets) to a model " \
                      "that reads the live data and drafts the work in your team's workflow." },
              { icon: "data", title: "Data is the unlock",
                body: "Every recommendation in this report depends on your account data being reachable " \
                      "in one place. That is the foundation the rest sits on." },
            ],
            diagram: {
              silos: [
                { label: "Amazon Ads" }, { label: "Seller Central" },
                { label: "Spreadsheets" }, { label: "Slack threads" },
                { label: "Notion docs" },
              ],
              connected: [
                { label: "One connected workspace" },
              ],
              caption: "Today the account picture is split across five places. Connected, it becomes one " \
                       "source the whole team and AI can act on.",
            },
          },

          journey: {
            stages: [
              { id: "STAGE-1", label: "How you work", state: "done",
                sub: "Mapped your current delivery end to end" },
              { id: "STAGE-2", label: "What we found", state: "done",
                sub: "Pain points and optimisations from the sessions" },
              { id: "STAGE-3", label: "Hidden costs", state: "done",
                sub: "The time and money quantified" },
              { id: "STAGE-4", label: "AI blueprint", state: "done",
                sub: "What to build, in what order" },
            ],
          },

          sessions: [
            { id: "SES-01", badge: "Session 1", complete: true, date: "2026-04-09",
              title: "Acquisition and onboarding walkthrough",
              summary: "Daniel and Ava walked through how leads come in, how proposals get built, " \
                       "and what it takes to stand up a new Amazon client.",
              stage_tags: %w[Acquisition Onboarding] },
            { id: "SES-02", badge: "Session 2", complete: true, date: "2026-04-16",
              title: "PPC delivery deep dive",
              summary: "Priya and Sam showed the weekly bid, budget and search-term routine across the " \
                       "client portfolio and where the hours go.",
              stage_tags: ["PPC Management", "Reporting"] },
            { id: "SES-03", badge: "Session 3", complete: true, date: "2026-04-23",
              title: "Catalogue, reporting and billing",
              summary: "Marcus and Ava covered listing optimisation, catalogue health, client reporting " \
                       "and the month end spend reconciliation.",
              stage_tags: ["Catalogue Optimization", "Reporting & Billing"] },
          ],

          deliverables: [
            { key: "process-map", heading: "Your process map is ready",
              sub: "Every step of how Scaleforte delivers today, with the pain points marked.",
              state: "available", cta_label: "Open process map", locked_tooltip: nil },
            { key: "findings", heading: "What we discussed",
              sub: "The pain points and optimisation ideas, grouped by area.",
              state: "available", cta_label: "View findings", locked_tooltip: nil },
            { key: "waste", heading: "Hidden costs uncovered",
              sub: "The operational waste quantified in hours and dollars.",
              state: "available", cta_label: "View hidden costs", locked_tooltip: nil },
            { key: "blueprint", heading: "Your AI blueprint",
              sub: "What to build, the order, the cost and the payback.",
              state: "available", cta_label: "View the blueprint", locked_tooltip: nil },
            { key: "comprehensive-report", heading: "Full audit report",
              sub: "Everything in one long form document you can print or save.",
              state: "available", cta_label: "Open full report", locked_tooltip: nil },
          ],

          downloads: [
            { title: "How you work", description: "Current state process map across five stages.",
              deliverable_key: "process-map", format_label: "Web document" },
            { title: "What we found", description: "Pain points and optimisation opportunities.",
              deliverable_key: "findings", format_label: "Web document" },
            { title: "Hidden costs", description: "Operational waste quantified by area.",
              deliverable_key: "waste", format_label: "Web document" },
            { title: "AI blueprint", description: "Roadmap, costs and priority matrix.",
              deliverable_key: "blueprint", format_label: "Web document" },
            { title: "Full audit report", description: "The complete report, print friendly.",
              deliverable_key: "comprehensive-report", format_label: "Printable" },
          ],

          prototype: {
            heading: "See your future workspace in action",
            sub: "A clickable prototype of the connected Scaleforte delivery workspace, built from " \
                 "everything in this blueprint.",
            cta_label: "Open prototype",
            url: nil,
            enabled: false,
          },

          footer: { note: "Lumelogics. Scaleforte business operations audit. Delivered May 2026." },

          process_map: {
            intro: "This is how Scaleforte delivers today, captured across three working sessions. " \
                   "Steps marked as pain points are where the team told us the time goes.",
            legend: [
              { type: "standard", label: "Standard step", description: "Routine work, running as intended." },
              { type: "decision", label: "Decision", description: "A judgement call or branch in the flow." },
              { type: "automation", label: "Automation candidate", description: "Repetitive and rules based." },
              { type: "pain_point", label: "Pain point", description: "Named by the team as slow or costly." },
            ],
            team: [
              { id: "PERSON-1", name: "Daniel Cho", role: "Founder and strategy" },
              { id: "PERSON-2", name: "Priya Nair", role: "Head of PPC" },
              { id: "PERSON-3", name: "Sam Ortiz", role: "PPC analyst" },
              { id: "PERSON-4", name: "Marcus Webb", role: "Catalogue lead" },
              { id: "PERSON-5", name: "Ava Thompson", role: "Account manager" },
            ],
            tools: [
              { id: "TOOL-1", name: "Amazon Ads console", category: "Advertising" },
              { id: "TOOL-2", name: "Seller Central", category: "Marketplace" },
              { id: "TOOL-3", name: "Helium 10", category: "Research" },
              { id: "TOOL-4", name: "Google Sheets", category: "Data" },
              { id: "TOOL-5", name: "Slack", category: "Comms" },
              { id: "TOOL-6", name: "Notion", category: "Docs" },
              { id: "TOOL-7", name: "Xero", category: "Finance" },
              { id: "TOOL-8", name: "ClickUp", category: "Project management" },
            ],
            stages: [
              {
                id: "PSTAGE-1", title: "Acquisition", summary: "From inbound lead to signed client.",
                steps: [
                  { id: "STEP-1-1", title: "Lead intake", description: "Inbound arrives by email, " \
                    "referral or the site form and lands in a shared inbox.", type: "standard",
                    confidence: "high", owners: ["PERSON-5"], tools: ["TOOL-5"],
                    time_estimate: { qty: 2, unit: "hours", frequency: "weekly" } },
                  { id: "STEP-1-2", title: "Manual prospect audit", description: "An analyst pulls the " \
                    "prospect's Amazon data by hand and builds an audit deck for the pitch.",
                    type: "pain_point", confidence: "high", owners: ["PERSON-3"],
                    tools: ["TOOL-3", "TOOL-4"],
                    time_estimate: { qty: 6, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-010",
                    quote: { text: "Every proposal is a from scratch audit. It is hours before we even " \
                             "know if they are a fit.", speaker: "Daniel Cho", session_ref: "SES-01",
                             recording_timestamp: "00:12:40", recording_url: nil } },
                  { id: "STEP-1-3", title: "Proposal and scope", description: "Daniel reviews the audit, " \
                    "sets scope and pricing, and sends the proposal.", type: "decision",
                    confidence: "high", owners: ["PERSON-1"], tools: ["TOOL-6"],
                    time_estimate: { qty: 2, unit: "hours", frequency: "weekly" } },
                ],
              },
              {
                id: "PSTAGE-2", title: "Onboarding", summary: "Standing up a new Amazon client.",
                steps: [
                  { id: "STEP-2-1", title: "Access and data collection", description: "Ava chases " \
                    "advertising and Seller Central access and brand assets over email and Slack.",
                    type: "pain_point", confidence: "high", owners: ["PERSON-5"],
                    tools: ["TOOL-5", "TOOL-2"],
                    time_estimate: { qty: 4, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-006",
                    quote: { text: "Onboarding drags because we are always waiting on access and " \
                             "re asking for the same things.", speaker: "Ava Thompson",
                             session_ref: "SES-01", recording_timestamp: "00:41:15", recording_url: nil } },
                  { id: "STEP-2-2", title: "Baseline and account setup", description: "The team records " \
                    "a performance baseline and sets up tracking sheets per client.", type: "standard",
                    confidence: "medium", owners: ["PERSON-3"], tools: ["TOOL-4"],
                    time_estimate: { qty: 3, unit: "hours", frequency: "weekly" } },
                  { id: "STEP-2-3", title: "Kickoff", description: "Daniel and Ava run the kickoff call " \
                    "and confirm goals.", type: "standard", confidence: "high",
                    owners: ["PERSON-1", "PERSON-5"], tools: ["TOOL-5"],
                    time_estimate: { qty: 1, unit: "hours", frequency: "weekly" } },
                ],
              },
              {
                id: "PSTAGE-3", title: "PPC management", summary: "The weekly advertising delivery loop.",
                steps: [
                  { id: "STEP-3-1", title: "Bid and budget adjustments", description: "Analysts review " \
                    "every campaign and adjust bids and budgets account by account in the Ads console.",
                    type: "pain_point", confidence: "high", owners: ["PERSON-2", "PERSON-3"],
                    tools: ["TOOL-1", "TOOL-4"],
                    time_estimate: { qty: 12, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-001",
                    quote: { text: "Two of us spend the better part of two days a week just nudging " \
                             "bids across the portfolio.", speaker: "Priya Nair", session_ref: "SES-02",
                             recording_timestamp: "00:08:55", recording_url: nil } },
                  { id: "STEP-3-2", title: "Search term harvesting", description: "Sam exports search " \
                    "term reports and mines new keywords and negatives by hand.", type: "automation",
                    confidence: "high", owners: ["PERSON-3"], tools: ["TOOL-1", "TOOL-4"],
                    time_estimate: { qty: 6, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-003",
                    quote: { text: "The search term mining is pure pattern work but it still eats a " \
                             "full morning.", speaker: "Sam Ortiz", session_ref: "SES-02",
                             recording_timestamp: "00:22:30", recording_url: nil } },
                  { id: "STEP-3-3", title: "Performance check and flags", description: "Priya reviews " \
                    "ACOS and TACOS and decides which accounts need attention.", type: "decision",
                    confidence: "medium", owners: ["PERSON-2"], tools: ["TOOL-1"],
                    time_estimate: { qty: 3, unit: "hours", frequency: "weekly" } },
                ],
              },
              {
                id: "PSTAGE-4", title: "Catalogue optimization", summary: "Listing and content delivery.",
                steps: [
                  { id: "STEP-4-1", title: "Keyword and competitor research", description: "Marcus runs " \
                    "research per catalogue in Helium 10 and assembles it into a brief.", type: "pain_point",
                    confidence: "high", owners: ["PERSON-4"], tools: ["TOOL-3", "TOOL-4"],
                    time_estimate: { qty: 5, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-005",
                    quote: { text: "Research is the same five steps every catalogue, just different " \
                             "products.", speaker: "Marcus Webb", session_ref: "SES-03",
                             recording_timestamp: "00:05:10", recording_url: nil } },
                  { id: "STEP-4-2", title: "Listing copy and A plus content", description: "Marcus drafts " \
                    "titles, bullets and A plus content from a blank doc each time.", type: "pain_point",
                    confidence: "high", owners: ["PERSON-4"], tools: ["TOOL-6", "TOOL-2"],
                    time_estimate: { qty: 9, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-004",
                    quote: { text: "Writing listings from scratch is the single biggest time sink on " \
                             "my side.", speaker: "Marcus Webb", session_ref: "SES-03",
                             recording_timestamp: "00:17:45", recording_url: nil } },
                  { id: "STEP-4-3", title: "Catalogue health checks", description: "Someone manually " \
                    "scans for suppressed listings and buy box loss across clients.", type: "automation",
                    confidence: "medium", owners: ["PERSON-4"], tools: ["TOOL-2"],
                    time_estimate: { qty: 4.5, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-009" },
                ],
              },
              {
                id: "PSTAGE-5", title: "Reporting and billing",
                summary: "Client reporting, retention and month end.",
                steps: [
                  { id: "STEP-5-1", title: "Weekly client reports", description: "Each analyst rebuilds " \
                    "a report per client by copying numbers into a slide template.", type: "pain_point",
                    confidence: "high", owners: ["PERSON-2", "PERSON-3"], tools: ["TOOL-1", "TOOL-4"],
                    time_estimate: { qty: 8, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-002",
                    quote: { text: "Friday is reporting day and it is gone by lunch, every week, per " \
                             "person.", speaker: "Priya Nair", session_ref: "SES-02",
                             recording_timestamp: "00:34:20", recording_url: nil } },
                  { id: "STEP-5-2", title: "Status updates and inbox triage", description: "Ava keeps " \
                    "clients updated across email and Slack and chases internal answers.",
                    type: "pain_point", confidence: "medium", owners: ["PERSON-5"], tools: ["TOOL-5"],
                    time_estimate: { qty: 7, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-007" },
                  { id: "STEP-5-3", title: "Spend reconciliation for invoicing", description: "At month " \
                    "end ad spend is reconciled across accounts and passed to Xero.", type: "pain_point",
                    confidence: "high", owners: ["PERSON-5"], tools: ["TOOL-1", "TOOL-7"],
                    time_estimate: { qty: 3.5, unit: "hours", frequency: "weekly" },
                    pain_point_ref: "PP-008",
                    quote: { text: "Reconciling spend before we can invoice is fiddly and easy to get " \
                             "wrong.", speaker: "Ava Thompson", session_ref: "SES-03",
                             recording_timestamp: "00:48:05", recording_url: nil } },
                ],
              },
            ],
          },

          categories: [
            { id: "CAT-1", label: "Acquisition", description: "Winning new Amazon clients." },
            { id: "CAT-2", label: "Onboarding", description: "Standing up a new client." },
            { id: "CAT-3", label: "PPC Management", description: "Weekly advertising delivery." },
            { id: "CAT-4", label: "Catalogue Optimization", description: "Listing and content work." },
            { id: "CAT-5", label: "Reporting & Billing", description: "Reporting, retention, month end." },
          ],

          findings: {
            intro: "These are the points raised across the three sessions, grouped by area. Pain " \
                   "points are what the team named as slow or costly. Optimisations are ideas we " \
                   "discussed together. This is not the proposed solution, that is the blueprint.",
            pain_points: [
              { ref_id: "PP-001", title: "Bid and budget changes are fully manual across every account",
                severity: "HIGH", category: "CAT-3", source_session: "SES-02",
                description: "Two analysts spend roughly two days a week adjusting bids and budgets " \
                             "account by account with no automation." },
              { ref_id: "PP-002", title: "Weekly client reports are rebuilt by hand per client",
                severity: "HIGH", category: "CAT-5", source_session: "SES-02",
                description: "Reporting consumes a half day per analyst every week copying numbers " \
                             "into a template." },
              { ref_id: "PP-003", title: "Search term harvesting is manual pattern work",
                severity: "MEDIUM", category: "CAT-3", source_session: "SES-02",
                description: "Mining keywords and negatives from search term reports is repetitive and " \
                             "rules based but still done by hand." },
              { ref_id: "PP-004", title: "Listing copy is written from scratch every time",
                severity: "HIGH", category: "CAT-4", source_session: "SES-03",
                description: "Titles, bullets and A plus content start from a blank document for each " \
                             "product with no reusable scaffold." },
              { ref_id: "PP-005", title: "Catalogue research repeats the same steps per client",
                severity: "MEDIUM", category: "CAT-4", source_session: "SES-03",
                description: "The keyword and competitor research routine is identical across catalogues " \
                             "but redone manually each time." },
              { ref_id: "PP-006", title: "Onboarding stalls waiting on access and assets",
                severity: "MEDIUM", category: "CAT-2", source_session: "SES-01",
                description: "Access and brand assets are chased over email and Slack with no structured " \
                             "intake." },
              { ref_id: "PP-007", title: "Client status updates are ad hoc and time consuming",
                severity: "MEDIUM", category: "CAT-5", source_session: "SES-03",
                description: "Keeping clients informed is spread across inboxes and threads with no " \
                             "single view." },
              { ref_id: "PP-008", title: "Spend reconciliation before invoicing is error prone",
                severity: "MEDIUM", category: "CAT-5", source_session: "SES-03",
                description: "Month end ad spend is reconciled by hand across accounts before invoices " \
                             "can go out." },
              { ref_id: "PP-009", title: "Catalogue health is monitored manually",
                severity: "MEDIUM", category: "CAT-4", source_session: "SES-03",
                description: "Suppressed listings and buy box loss are caught only when someone looks." },
              { ref_id: "PP-010", title: "Every proposal is a from scratch audit",
                severity: "HIGH", category: "CAT-1", source_session: "SES-01",
                description: "Pitching a prospect means hours of manual data pulling and deck building " \
                             "before fit is even known." },
            ],
            optimisations: [
              { ref_id: "OPT-001", title: "Rules driven bid and budget assistant",
                severity: "HIGH", category: "CAT-3", source_session: "SES-02",
                description: "A copilot that proposes bid and budget moves from live data for the " \
                             "analyst to approve." },
              { ref_id: "OPT-002", title: "One click client reporting",
                severity: "HIGH", category: "CAT-5", source_session: "SES-02",
                description: "Generate the weekly client report from the account data automatically." },
              { ref_id: "OPT-003", title: "Automated search term harvesting",
                severity: "MEDIUM", category: "CAT-3", source_session: "SES-02",
                description: "Scheduled mining of keywords and negatives with a review queue." },
              { ref_id: "OPT-004", title: "Listing content generation scaffold",
                severity: "HIGH", category: "CAT-4", source_session: "SES-03",
                description: "Draft titles, bullets and A plus content from the research brief." },
              { ref_id: "OPT-005", title: "Reusable research workflow",
                severity: "MEDIUM", category: "CAT-4", source_session: "SES-03",
                description: "A repeatable research assistant that outputs a standard brief." },
              { ref_id: "OPT-006", title: "Structured onboarding intake",
                severity: "MEDIUM", category: "CAT-2", source_session: "SES-01",
                description: "A guided intake that collects access and assets and tracks what is " \
                             "outstanding." },
              { ref_id: "OPT-007", title: "Unified client workspace",
                severity: "MEDIUM", category: "CAT-5", source_session: "SES-03",
                description: "One place for status, deliverables and updates per client." },
              { ref_id: "OPT-008", title: "Catalogue health monitor",
                severity: "MEDIUM", category: "CAT-4", source_session: "SES-03",
                description: "Automatic alerts on suppressions and buy box loss." },
            ],
          },

          waste: {
            intro: "Each item below is time the team named in the sessions, valued at the relevant " \
                   "role rate. These are conservative and based on what staff told us, not estimates " \
                   "we invented.",
            kpi_summary: {
              total_opportunities: 10,
              recoverable_hours_per_week: 65.0,
              default_rate_label: "$45/hr applied when a role rate is unavailable",
            },
            cost_formula: "Annual Cost = Weekly Hours x People Affected x Hourly Rate x 52",
            opportunities: [
              { ref_id: "W-001", title: "Manual bid and budget adjustments", category: "CAT-3",
                description: "Two analysts adjusting bids and budgets account by account every week.",
                annual_cost: 62_400, weekly_hours: 12.0, hourly_rate: 50, people_affected: 2,
                priority: "high", pain_point_ref: "PP-001",
                quote: { text: "The better part of two days a week, every week.", speaker: "Priya Nair",
                         session_ref: "SES-02", recording_timestamp: "00:09:30", recording_url: nil } },
              { ref_id: "W-002", title: "Building weekly client reports by hand", category: "CAT-5",
                description: "Each analyst rebuilds a report per client into a slide template weekly.",
                annual_cost: 37_440, weekly_hours: 8.0, hourly_rate: 45, people_affected: 2,
                priority: "high", pain_point_ref: "PP-002",
                quote: { text: "Reporting day is gone by lunch, per person.", speaker: "Priya Nair",
                         session_ref: "SES-02", recording_timestamp: "00:34:40", recording_url: nil } },
              { ref_id: "W-003", title: "Search term harvesting and negatives", category: "CAT-3",
                description: "Manually mining keywords and negatives from search term reports.",
                annual_cost: 14_040, weekly_hours: 6.0, hourly_rate: 45, people_affected: 1,
                priority: "medium", pain_point_ref: "PP-003",
                quote: { text: "Pure pattern work, still a full morning.", speaker: "Sam Ortiz",
                         session_ref: "SES-02", recording_timestamp: "00:23:05", recording_url: nil } },
              { ref_id: "W-004", title: "Listing copy and A plus content from scratch", category: "CAT-4",
                description: "Drafting titles, bullets and A plus content from a blank doc per product.",
                annual_cost: 18_720, weekly_hours: 9.0, hourly_rate: 40, people_affected: 1,
                priority: "high", pain_point_ref: "PP-004",
                quote: { text: "The single biggest time sink on my side.", speaker: "Marcus Webb",
                         session_ref: "SES-03", recording_timestamp: "00:18:10", recording_url: nil } },
              { ref_id: "W-005", title: "Keyword and competitor research per catalogue", category: "CAT-4",
                description: "Repeating the same research routine for every catalogue by hand.",
                annual_cost: 10_400, weekly_hours: 5.0, hourly_rate: 40, people_affected: 1,
                priority: "medium", pain_point_ref: "PP-005",
                quote: { text: "Same five steps every catalogue.", speaker: "Marcus Webb",
                         session_ref: "SES-03", recording_timestamp: "00:05:35", recording_url: nil } },
              { ref_id: "W-006", title: "Onboarding data collection and access chase", category: "CAT-2",
                description: "Chasing advertising and Seller Central access and brand assets manually.",
                annual_cost: 8_736, weekly_hours: 4.0, hourly_rate: 42, people_affected: 1,
                priority: "medium", pain_point_ref: "PP-006",
                quote: { text: "Always waiting on access, re asking for the same things.",
                         speaker: "Ava Thompson", session_ref: "SES-01",
                         recording_timestamp: "00:42:00", recording_url: nil } },
              { ref_id: "W-007", title: "Reconciling ad spend for invoicing", category: "CAT-5",
                description: "Month end reconciliation of spend across accounts before invoicing.",
                annual_cost: 6_916, weekly_hours: 3.5, hourly_rate: 38, people_affected: 1,
                priority: "medium", pain_point_ref: "PP-008",
                quote: { text: "Fiddly and easy to get wrong.", speaker: "Ava Thompson",
                         session_ref: "SES-03", recording_timestamp: "00:48:30", recording_url: nil } },
              { ref_id: "W-008", title: "Client status updates and inbox triage", category: "CAT-5",
                description: "Keeping clients updated across email and Slack and chasing answers.",
                annual_cost: 15_288, weekly_hours: 7.0, hourly_rate: 42, people_affected: 1,
                priority: "medium", pain_point_ref: "PP-007",
                quote: { text: "It is constant and it is everywhere.", speaker: "Ava Thompson",
                         session_ref: "SES-03", recording_timestamp: "00:51:15", recording_url: nil } },
              { ref_id: "W-009", title: "Catalogue health and suppression monitoring", category: "CAT-4",
                description: "Manually scanning for suppressed listings and buy box loss.",
                annual_cost: 9_360, weekly_hours: 4.5, hourly_rate: 40, people_affected: 1,
                priority: "medium", pain_point_ref: "PP-009",
                quote: nil },
              { ref_id: "W-010", title: "Manual prospect audits and proposal building", category: "CAT-1",
                description: "Pulling prospect data and building an audit deck for every pitch.",
                annual_cost: 15_600, weekly_hours: 6.0, hourly_rate: 50, people_affected: 1,
                priority: "high", pain_point_ref: "PP-010",
                quote: { text: "Hours before we even know if they are a fit.", speaker: "Daniel Cho",
                         session_ref: "SES-01", recording_timestamp: "00:13:05", recording_url: nil } },
            ],
          },

          blueprint: {
            intro: "What we would build, in the order that returns value fastest. Every item ties " \
                   "back to a pain point and the waste it removes.",
            exec_kpis: [
              { label: "Identified annual opportunity value", value: "$198,900",
                sub: "Total quantified waste across the operation" },
              { label: "Opportunities identified", value: "10",
                sub: "Distinct sources of recoverable time" },
              { label: "Recoverable time", value: "65 hrs/wk",
                sub: "Across the team, at current volume" },
              { label: "Annual value unlocked", value: "$184,000",
                sub: "Recovered once the blueprint is built" },
            ],
            framework_layers: [
              { id: "LAYER-1", label: "Data",
                description: "Account records, campaign data, search terms, catalogue and spend. If it " \
                             "is siloed nothing above works, including AI." },
              { id: "LAYER-2", label: "Systems",
                description: "Amazon Ads, Seller Central, Sheets and the tools the team uses to see and " \
                             "act on the data." },
              { id: "LAYER-3", label: "AI",
                description: "Reads the connected data, drafts the work and recommends moves, but only " \
                             "if it can reach the data." },
            ],
            solution_types: [
              { id: "ST-1", label: "Cowork plugin", description: "The team talks to AI in plain " \
                "language. It reads the data and drafts the work in their flow.",
                typical_timeline: "4 to 8 weeks", color_token: "brand" },
              { id: "ST-2", label: "Background automation", description: "Runs with no staff " \
                "interaction, triggered by events on a schedule.",
                typical_timeline: "2 to 6 weeks", color_token: "success" },
              { id: "ST-3", label: "Custom build", description: "A purpose built application owned by " \
                "you, designed around the exact workflow.",
                typical_timeline: "6 to 16 weeks", color_token: "info" },
              { id: "ST-4", label: "Data foundation", description: "Connect and clean the data so the " \
                "rest can run on it.", typical_timeline: "2 to 5 weeks", color_token: "muted" },
            ],
            domains: [
              { id: "DOM-1", label: "Acquisition" },
              { id: "DOM-2", label: "Onboarding" },
              { id: "DOM-3", label: "PPC Management" },
              { id: "DOM-4", label: "Catalogue Optimization" },
              { id: "DOM-5", label: "Reporting & Billing" },
            ],
            opportunities: [
              { ref_id: "S-001", title: "AI bid and budget copilot",
                summary: "A copilot that reads live campaign data and proposes bid and budget moves " \
                         "for an analyst to approve in seconds instead of hours.",
                annual_value: 55_000, build_cost_min: 18_000, build_cost_max: 28_000,
                payback_months: 5.0, timeline_weeks: 6, solution_type: "ST-3",
                risk_level: "medium", risk_description: "Needs careful guardrails on automated bid " \
                  "changes. We stage it as approve first, then auto.",
                problems_solved: ["PP-001", "PP-003"], waste_eliminated: ["W-001", "W-003"],
                methodology: "Derived from the bid and harvest waste recovered at 80 percent.",
                dev_hours: 90, pm_hours: 24, confidence: "MEDIUM",
                domains: ["DOM-3"], layers: ["LAYER-2", "LAYER-3"],
                quote: { text: "If the bids drafted themselves we would take on more accounts " \
                         "tomorrow.", speaker: "Priya Nair", session_ref: "SES-02",
                         recording_timestamp: "00:10:05", recording_url: nil } },
              { ref_id: "S-002", title: "Automated client reporting",
                summary: "Generate the weekly client report straight from account data, branded and " \
                         "ready to send.",
                annual_value: 34_000, build_cost_min: 9_000, build_cost_max: 15_000,
                payback_months: 3.5, timeline_weeks: 4, solution_type: "ST-2",
                risk_level: "low", risk_description: "Low. Read only on the data, output reviewed " \
                  "before send.",
                problems_solved: ["PP-002"], waste_eliminated: ["W-002", "W-007"],
                methodology: "Reporting and reconciliation waste recovered near fully.",
                dev_hours: 50, pm_hours: 14, confidence: "HIGH",
                domains: ["DOM-5"], layers: ["LAYER-1", "LAYER-2"],
                quote: { text: "Give me Friday back.", speaker: "Sam Ortiz", session_ref: "SES-02",
                         recording_timestamp: "00:36:00", recording_url: nil } },
              { ref_id: "S-003", title: "Listing content generation plugin",
                summary: "Draft titles, bullets and A plus content from the research brief in the " \
                         "team's flow, ready to refine.",
                annual_value: 22_000, build_cost_min: 8_000, build_cost_max: 14_000,
                payback_months: 4.0, timeline_weeks: 4, solution_type: "ST-1",
                risk_level: "low", risk_description: "Low. Drafts only, the catalogue lead edits and " \
                  "approves.",
                problems_solved: ["PP-004"], waste_eliminated: ["W-004"],
                methodology: "Listing drafting waste recovered at around 85 percent.",
                dev_hours: 46, pm_hours: 12, confidence: "MEDIUM",
                domains: ["DOM-4"], layers: ["LAYER-2", "LAYER-3"],
                quote: { text: "A scaffold instead of a blank page would change my week.",
                         speaker: "Marcus Webb", session_ref: "SES-03",
                         recording_timestamp: "00:19:20", recording_url: nil } },
              { ref_id: "S-004", title: "Keyword and competitor research assistant",
                summary: "A repeatable assistant that runs the research routine and outputs a standard " \
                         "brief per catalogue.",
                annual_value: 14_000, build_cost_min: 6_000, build_cost_max: 10_000,
                payback_months: 4.0, timeline_weeks: 3, solution_type: "ST-1",
                risk_level: "low", risk_description: "Low. Outputs a brief for review.",
                problems_solved: ["PP-005"], waste_eliminated: ["W-005"],
                methodology: "Research waste recovered at around 75 percent.",
                dev_hours: 34, pm_hours: 8, confidence: "MEDIUM",
                domains: ["DOM-4"], layers: ["LAYER-2", "LAYER-3"], quote: nil },
              { ref_id: "S-005", title: "Onboarding intake and access automation",
                summary: "A guided intake that collects access and assets and tracks what is " \
                         "outstanding automatically.",
                annual_value: 9_000, build_cost_min: 5_000, build_cost_max: 9_000,
                payback_months: 6.0, timeline_weeks: 3, solution_type: "ST-2",
                risk_level: "low", risk_description: "Low. Process automation, no account changes.",
                problems_solved: ["PP-006"], waste_eliminated: ["W-006"],
                methodology: "Onboarding chase waste recovered at around 70 percent.",
                dev_hours: 30, pm_hours: 8, confidence: "HIGH",
                domains: ["DOM-2"], layers: ["LAYER-1", "LAYER-2"], quote: nil },
              { ref_id: "S-006", title: "Search term harvesting automation",
                summary: "Scheduled mining of keywords and negatives with a short review queue.",
                annual_value: 12_000, build_cost_min: 5_000, build_cost_max: 9_000,
                payback_months: 4.5, timeline_weeks: 3, solution_type: "ST-2",
                risk_level: "low", risk_description: "Low. Suggestions reviewed before applied.",
                problems_solved: ["PP-003"], waste_eliminated: ["W-003"],
                methodology: "Harvest waste recovered at around 85 percent.",
                dev_hours: 28, pm_hours: 7, confidence: "MEDIUM",
                domains: ["DOM-3"], layers: ["LAYER-1", "LAYER-2"], quote: nil },
              { ref_id: "S-007", title: "Unified client workspace and status hub",
                summary: "One place per client for status, deliverables and updates, replacing the " \
                         "scattered threads.",
                annual_value: 16_000, build_cost_min: 12_000, build_cost_max: 22_000,
                payback_months: 9.0, timeline_weeks: 8, solution_type: "ST-3",
                risk_level: "medium", risk_description: "Medium. Adoption is the risk, we plan a phased " \
                  "rollout.",
                problems_solved: ["PP-007", "PP-008"], waste_eliminated: ["W-008"],
                methodology: "Status and triage waste recovered at around 60 percent.",
                dev_hours: 80, pm_hours: 22, confidence: "MEDIUM",
                domains: ["DOM-5"], layers: ["LAYER-1", "LAYER-2", "LAYER-3"], quote: nil },
              { ref_id: "S-008", title: "Catalogue health monitor",
                summary: "Automatic alerts on suppressed listings and buy box loss across clients.",
                annual_value: 8_000, build_cost_min: 4_000, build_cost_max: 8_000,
                payback_months: 5.0, timeline_weeks: 2, solution_type: "ST-2",
                risk_level: "low", risk_description: "Low. Monitoring and alerting only.",
                problems_solved: ["PP-009"], waste_eliminated: ["W-009"],
                methodology: "Monitoring waste recovered at around 85 percent.",
                dev_hours: 24, pm_hours: 6, confidence: "HIGH",
                domains: ["DOM-4"], layers: ["LAYER-1", "LAYER-2"], quote: nil },
              { ref_id: "S-009", title: "Prospect audit and proposal builder",
                summary: "Pull prospect data and assemble the audit and proposal draft in minutes " \
                         "instead of hours.",
                annual_value: 14_000, build_cost_min: 7_000, build_cost_max: 12_000,
                payback_months: 5.0, timeline_weeks: 4, solution_type: "ST-1",
                risk_level: "low", risk_description: "Low. Produces a draft the founder reviews.",
                problems_solved: ["PP-010"], waste_eliminated: ["W-010"],
                methodology: "Proposal audit waste recovered at around 80 percent.",
                dev_hours: 40, pm_hours: 10, confidence: "MEDIUM",
                domains: ["DOM-1"], layers: ["LAYER-2", "LAYER-3"],
                quote: { text: "A proposal in an afternoon instead of a week.", speaker: "Daniel Cho",
                         session_ref: "SES-01", recording_timestamp: "00:14:10", recording_url: nil } },
            ],
            priority_matrix: {
              x_axis_label: "Ease of implementation",
              y_axis_label: "Business impact",
              quadrants: [
                { id: "Q1", label: "Big swings", position: "tl" },
                { id: "Q2", label: "Future plans", position: "tr" },
                { id: "Q3", label: "Nice to haves", position: "bl" },
                { id: "Q4", label: "Quick wins", position: "br" },
              ],
            },
            video_gallery: [],
            roadmap: {
              intro: "Sequenced so the fastest payback ships first. Quick wins fund the bigger builds.",
              total_months: 9,
              initiatives: [
                { ref_id: "S-008", label: "Catalogue health monitor", start_month: 0,
                  duration_weeks: 2, solution_type: "ST-2",
                  tooltip: "Build $4k to $8k. Payback 5 mo. Value $8,000/yr." },
                { ref_id: "S-002", label: "Automated client reporting", start_month: 0,
                  duration_weeks: 4, solution_type: "ST-2",
                  tooltip: "Build $9k to $15k. Payback 3.5 mo. Value $34,000/yr." },
                { ref_id: "S-006", label: "Search term harvesting automation", start_month: 1,
                  duration_weeks: 3, solution_type: "ST-2",
                  tooltip: "Build $5k to $9k. Payback 4.5 mo. Value $12,000/yr." },
                { ref_id: "S-004", label: "Research assistant", start_month: 2,
                  duration_weeks: 3, solution_type: "ST-1",
                  tooltip: "Build $6k to $10k. Payback 4 mo. Value $14,000/yr." },
                { ref_id: "S-003", label: "Listing content plugin", start_month: 3,
                  duration_weeks: 4, solution_type: "ST-1",
                  tooltip: "Build $8k to $14k. Payback 4 mo. Value $22,000/yr." },
                { ref_id: "S-009", label: "Prospect audit builder", start_month: 3,
                  duration_weeks: 4, solution_type: "ST-1",
                  tooltip: "Build $7k to $12k. Payback 5 mo. Value $14,000/yr." },
                { ref_id: "S-005", label: "Onboarding intake automation", start_month: 4,
                  duration_weeks: 3, solution_type: "ST-2",
                  tooltip: "Build $5k to $9k. Payback 6 mo. Value $9,000/yr." },
                { ref_id: "S-001", label: "AI bid and budget copilot", start_month: 5,
                  duration_weeks: 6, solution_type: "ST-3",
                  tooltip: "Build $18k to $28k. Payback 5 mo. Value $55,000/yr." },
                { ref_id: "S-007", label: "Unified client workspace", start_month: 7,
                  duration_weeks: 8, solution_type: "ST-3",
                  tooltip: "Build $12k to $22k. Payback 9 mo. Value $16,000/yr." },
              ],
            },
          },

          report: {
            title: "Business Operations Audit",
            subtitle: "Scaleforte",
            prepared_for: "Daniel Cho, Scaleforte",
            prepared_on: "2026-05-12",
            executive_summary: "Across three sessions we mapped how Scaleforte delivers PPC and " \
              "catalogue work today. The operation is strong but a large share of senior time goes " \
              "to manual assembly: bid changes, reporting, research and listing drafting. We " \
              "quantified ten sources of recoverable time worth $198,900 a year and roughly 65 " \
              "hours a week. The blueprint recovers an estimated $184,000 a year, sequenced so the " \
              "fastest payback ships first.",
            sections: [
              { anchor: "executive-summary", title: "Executive summary", include: true },
              { anchor: "process-map", title: "Process map", include: true },
              { anchor: "findings", title: "Findings", include: true },
              { anchor: "waste", title: "Opportunity analysis", include: true },
              { anchor: "solutions", title: "Solutions", include: true },
            ],
            closing_note: "Next step is a working session to walk this through together and lock the " \
              "first sprint.",
          },
        }
      end
    end
  end
end
