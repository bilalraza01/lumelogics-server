module Api
  module V1
    # Public read-only endpoint for the client audit deliverable at
    # https://lumelogics.com/audit/<slug>. No auth, the slug (the client's
    # company name) is the capability key. Returns the entire structured
    # document from the single JSONB `content` column; the web app does all
    # shaping and number derivation. Modeled on VideosController#show_by_slug,
    # but read-only with no activity logging.
    class AuditsController < ApplicationController
      HIDDEN_STATUSES = %w[archived].freeze

      # GET /api/v1/audits/by-slug/:slug
      def by_slug
        audit = Audit.find_by(slug: params[:slug].to_s.downcase)
        return render(json: { error: "not_found" }, status: :not_found) unless audit
        if HIDDEN_STATUSES.include?(audit.status)
          return render(json: { error: "not_found" }, status: :not_found)
        end

        render json: {
          slug:         audit.slug,
          client_name:  audit.client_name,
          industry:     audit.industry,
          status:       audit.status,
          started_on:   audit.started_on,
          completed_on: audit.completed_on,
          content:      audit.content,
        }
      end
    end
  end
end
