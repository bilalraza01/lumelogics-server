class AdminUser < ApplicationRecord
  has_secure_password

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format:     { with: URI::MailTo::EMAIL_REGEXP }

  # has_secure_password already enforces a 72-byte max; add a floor. allow_nil
  # so loading/updating a record without touching the password stays valid.
  validates :password, length: { minimum: 8 }, allow_nil: true

  before_save { self.email = email.to_s.downcase.strip }
end
