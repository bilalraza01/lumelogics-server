require "rails_helper"

RSpec.describe AdminJwt do
  let(:secret) { "test_secret_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }

  around do |example|
    old = ENV["ADMIN_JWT_SECRET"]
    ENV["ADMIN_JWT_SECRET"] = secret
    example.run
    ENV["ADMIN_JWT_SECRET"] = old
  end

  describe ".encode/.decode" do
    it "round-trips an admin user id" do
      admin       = create(:admin_user)
      token, exp  = described_class.encode(admin)
      payload     = described_class.decode(token)

      expect(payload["sub"]).to eq(admin.id)
      expect(payload["admin"]).to eq(true)
      expect(payload["exp"]).to eq(exp)
    end

    it "raises on an expired token" do
      admin     = create(:admin_user)
      token, _e = described_class.encode(admin, expires_in: -1.minute)

      expect { described_class.decode(token) }.to raise_error(JWT::ExpiredSignature)
    end

    it "raises on a token signed with a different secret" do
      payload = { admin: true, sub: SecureRandom.uuid, exp: 1.hour.from_now.to_i }
      bad     = JWT.encode(payload, "wrong_secret", "HS256")

      expect { described_class.decode(bad) }.to raise_error(JWT::VerificationError)
    end
  end

  describe ".secret" do
    it "raises when ADMIN_JWT_SECRET is missing" do
      ENV["ADMIN_JWT_SECRET"] = ""
      expect { described_class.secret }.to raise_error(/ADMIN_JWT_SECRET/)
    end
  end
end
