# Public client audit deliverable, served read-only at
# lumelogics.com/audit/<slug>. The whole structured document lives in the
# single JSONB `content` column (see db/seeds/audits/*.rb for the shape);
# the web app does all rendering/derivation. Slugs are human-authored
# (the client's company name), so we validate the format instead of
# generating one like Video does.
class Audit < ApplicationRecord
  STATUSES = %w[in_progress in_review delivered archived].freeze

  validates :slug,
            presence: true,
            uniqueness: true,
            format: {
              with: /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/,
              message: "must be lowercase letters, numbers and hyphens",
            }
  validates :client_name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validate :content_shape

  # Slug is the public URL key.
  def to_param = slug

  private

  # Lenient structural guard so a malformed document written through the
  # admin API can never reach (and break) the public renderer. Checks the
  # top-level container types only, not every leaf, so the structured editor
  # stays free to evolve inner fields.
  HASH_KEYS  = %w[hero ai_moment journey prototype footer process_map
                  findings waste blueprint report].freeze
  ARRAY_KEYS = %w[sessions deliverables downloads categories].freeze

  def content_shape
    doc = content
    return errors.add(:content, "must be an object") unless doc.is_a?(Hash)

    doc = doc.deep_stringify_keys
    errors.add(:content, "is missing schema_version") unless doc.key?("schema_version")

    HASH_KEYS.each do |k|
      next if doc[k].is_a?(Hash)

      errors.add(:content, "#{k} must be an object")
    end
    ARRAY_KEYS.each do |k|
      next if doc[k].is_a?(Array)

      errors.add(:content, "#{k} must be an array")
    end

    %w[pain_points optimisations].each do |k|
      next if doc.dig("findings", k).is_a?(Array)

      errors.add(:content, "findings.#{k} must be an array")
    end
    errors.add(:content, "waste.opportunities must be an array") unless doc.dig("waste", "opportunities").is_a?(Array)
    errors.add(:content, "blueprint.opportunities must be an array") unless doc.dig("blueprint", "opportunities").is_a?(Array)
  end
end
