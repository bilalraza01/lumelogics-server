require "faraday"
require "json"

module Outreel
  # Thin Faraday wrapper around the Smartlead REST API. Rate-limited by callers
  # (PushService sleeps 0.25s per 400-lead chunk).
  class SmartleadClient
    class Error < StandardError; end

    class << self
      def list_campaigns
        get_json("campaigns")
      end

      def add_leads(campaign_id, leads)
        post_json("campaigns/#{campaign_id}/leads", { lead_list: leads })
      end

      def analytics(campaign_id)
        get_json("campaigns/#{campaign_id}/analytics")
      end

      private

      def get_json(path)
        response = conn.get(path.delete_prefix("/"), { api_key: api_key })
        parse!(response)
      end

      def post_json(path, body)
        response = conn.post(path.delete_prefix("/")) do |req|
          req.params[:api_key] = api_key
          req.headers["Content-Type"] = "application/json"
          req.body = JSON.dump(body)
        end
        parse!(response)
      end

      def parse!(response)
        body = response.body
        if response.status >= 400
          raise Error, "Smartlead #{response.status}: #{body.to_s[0, 500]}"
        end
        return body if body.is_a?(Hash) || body.is_a?(Array)
        return nil if body.nil? || body == ""
        JSON.parse(body)
      rescue JSON::ParserError
        body
      end

      def conn
        base = ENV.fetch("SMARTLEAD_API_BASE")
        base += "/" unless base.end_with?("/")
        @conn ||= Faraday.new(url: base) do |f|
          f.request :url_encoded
          f.response :json, content_type: /\bjson$/
          f.adapter Faraday.default_adapter
          f.options.timeout = 30
          f.options.open_timeout = 10
        end
      end

      def api_key
        ENV.fetch("SMARTLEAD_API_KEY")
      end

      def reset!
        @conn = nil
      end
    end
  end
end
