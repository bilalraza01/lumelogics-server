class LeadMagnetFileUploader < CarrierWave::Uploader::Base
  # Local disk. In the docker-compose dev setup the repo is bind-mounted
  # (`.:/app`), so files written under public/uploads persist on the host
  # across container restarts. For production the host serving /uploads needs
  # a persistent volume mounted there.
  storage :file

  def store_dir
    "uploads/lead_magnets/#{model.id}"
  end

  # Safe, non-executable document/asset types. "pdf" magnets are further
  # constrained to .pdf by the model.
  def extension_allowlist
    %w[pdf doc docx xls xlsx csv ppt pptx txt rtf zip png jpg jpeg gif webp]
  end

  # Keep the original filename but make it URL/disk safe.
  def filename
    return if original_filename.blank?
    @name ||= "#{secure_token}-#{sanitize(original_filename)}"
  end

  private

  def sanitize(name)
    name.to_s.gsub(/[^a-zA-Z0-9.\-_]+/, "-").gsub(/-+/, "-")
  end

  def secure_token
    model.instance_variable_get(:@_lm_token) ||
      model.instance_variable_set(:@_lm_token, SecureRandom.hex(4))
  end
end
