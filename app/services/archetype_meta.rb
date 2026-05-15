# Display strings + CTA for each archetype. Mirrored on the frontend
# (lumelogics-web/src/lib/assessment/archetypes.ts) — keep them in sync.
# See spec §3.3.

class ArchetypeMeta
  DATA = {
    "wishful_thinker" => {
      display: "The Wishful Thinker",
      verdict: "You like the idea of AI but the foundations aren't there yet. " \
               "You're 6+ months from ready, and that's a fixable problem.",
      cta:     {
        label: "Download the AI Readiness Playbook",
        url:   "https://lumelogics.com/free/ai-readiness-playbook",
      },
    },
    "aspirational_operator" => {
      display: "The Aspirational Operator",
      verdict: "You're building the right habits but key pieces are missing. " \
               "You're 3 to 6 months from ready. The gaps below tell you where to focus.",
      cta:     { label: "Book a free 20-minute readiness call", url: "https://lumelogics.com/audit" },
    },
    "coordinated_operator" => {
      display: "The Coordinated Operator",
      verdict: "Strong foundations with one or two real gaps. " \
               "You're closer to ready than you think.",
      cta:     { label: "Book a free 30-minute consult", url: "https://lumelogics.com/audit" },
    },
    "build_ready_operator" => {
      display: "The Build-Ready Operator",
      verdict: "You're ready. The only real question is which workflow to automate first.",
      cta:     { label: "Book the audit", url: "https://lumelogics.com/audit" },
    },
    "optimization_operator" => {
      display: "The Optimization Operator",
      verdict: "You're past 'ready.' At your level, AI is leveraging an already-tight operation. " \
               "The conversation is which advanced workflow.",
      cta:     { label: "Book an advanced workflow consult", url: "https://lumelogics.com/audit" },
    },
  }.freeze

  def self.for(archetype)
    DATA.fetch(archetype.to_s)
  end
end
