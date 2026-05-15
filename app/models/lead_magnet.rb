class LeadMagnet < ApplicationRecord
  # pdf / file  → an uploaded file (forced download for the lead)
  # google_doc  → a Google Docs/Sheets share URL (opens in a new tab)
  # external_url → any other URL (opens in a new tab)
  RESOURCE_TYPES = %w[pdf google_doc external_url file].freeze
  UPLOAD_TYPES   = %w[pdf file].freeze
  LINK_TYPES     = %w[google_doc external_url].freeze

  DEFAULT_CALENDLY_URL = "https://calendly.com/bilal-lumelogics/30min".freeze

  mount_uploader :resource_file, LeadMagnetFileUploader

  has_many :lead_magnet_requests, dependent: :destroy

  validates :slug,          presence: true, uniqueness: true,
                            format: { with: /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/,
                                      message: "must be lowercase, alphanumeric + hyphens" }
  validates :title,         presence: true
  validates :resource_type, presence: true, inclusion: { in: RESOURCE_TYPES }
  validates :email_subject, presence: true
  validate  :resource_presence
  validate  :pdf_extension

  def calendly_url_or_default
    calendly_url.presence || DEFAULT_CALENDLY_URL
  end

  # pdf / file → the lead should get a forced file download.
  # google_doc / external_url → open the URL in a new tab.
  def downloadable?
    UPLOAD_TYPES.include?(resource_type)
  end

  # True when there's an actual uploaded file backing this magnet (vs a legacy
  # pdf row that still points at a static resource_url).
  def stored_file?
    downloadable? && resource_file.present?
  end

  private

  def resource_presence
    if UPLOAD_TYPES.include?(resource_type)
      # Legacy rows may still carry a static resource_url with no upload —
      # accept either, but require at least one.
      if resource_file.blank? && resource_url.blank?
        errors.add(:resource_file, "is required for #{resource_type} lead magnets")
      end
    elsif LINK_TYPES.include?(resource_type) && resource_url.blank?
      errors.add(:resource_url, "can't be blank")
    end
  end

  def pdf_extension
    return unless resource_type == "pdf"
    return if resource_file.blank?

    ext = File.extname(resource_file.path.to_s).delete(".").downcase
    errors.add(:resource_file, "must be a PDF") unless ext == "pdf"
  end
end
