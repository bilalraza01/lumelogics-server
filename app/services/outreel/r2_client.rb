require "aws-sdk-s3"

module Outreel
  # Cloudflare R2 = S3-compatible. Upload local MP4/GIF, return a public URL
  # served by R2_PUBLIC_URL (CDN in front of the bucket).
  class R2Client
    class << self
      def upload_file(local_path, key, content_type)
        bucket = ENV.fetch("R2_BUCKET")
        File.open(local_path, "rb") do |io|
          client.put_object(
            bucket:       bucket,
            key:          key,
            body:         io,
            content_type: content_type,
          )
        end
        public_url(key)
      end

      def public_url(key)
        "#{ENV.fetch('R2_PUBLIC_URL')}/#{key}"
      end

      def client
        @client ||= Aws::S3::Client.new(
          access_key_id:     ENV.fetch("R2_ACCESS_KEY_ID"),
          secret_access_key: ENV.fetch("R2_SECRET_ACCESS_KEY"),
          endpoint:          "https://#{ENV.fetch('R2_ACCOUNT_ID')}.r2.cloudflarestorage.com",
          region:            "auto",
          force_path_style:  true,
        )
      end

      def reset!
        @client = nil
      end
    end
  end
end
