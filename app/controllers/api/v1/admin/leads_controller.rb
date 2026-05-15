module Api
  module V1
    module Admin
      # A "lead" is an email aggregated across all of its lead_magnet_requests.
      # No `leads` table — purely a read-only projection.
      class LeadsController < ApplicationController
        include AdminAuthentication

        DEFAULT_PER_PAGE = 50
        MAX_PER_PAGE     = 200

        # GET /api/v1/admin/leads?page=&per_page=&q=
        def index
          scope = LeadMagnetRequest.all
          if params[:q].present?
            scope = scope.where("email ILIKE ?", "%#{params[:q].to_s.downcase.strip}%")
          end

          grouped = scope.group(:email).select(
            "email",
            "COUNT(*)             AS request_count",
            "COUNT(verified_at)   AS verified_count",
            "MIN(created_at)      AS first_seen_at",
            "MAX(created_at)      AS last_seen_at",
          ).order(Arel.sql("MAX(created_at) DESC"))

          page     = [params[:page].to_i, 1].max
          per_page = [params[:per_page].to_i.nonzero? || DEFAULT_PER_PAGE, MAX_PER_PAGE].min
          # ActiveRecord wraps GROUP BY queries in a COUNT subquery for .count.
          total    = scope.distinct.count(:email)
          rows     = grouped.offset((page - 1) * per_page).limit(per_page)

          render json: {
            data: rows.map { |r| summary_json(r) },
            pagination: { page: page, per_page: per_page, total: total },
          }
        end

        # GET /api/v1/admin/leads/:email
        def show
          email = params[:email].to_s.downcase.strip
          requests = LeadMagnetRequest.includes(:lead_magnet)
                                      .where(email: email)
                                      .order(created_at: :desc)
          return render(json: { error: "not_found" }, status: :not_found) if requests.empty?

          render json: {
            email:          email,
            request_count:  requests.size,
            verified_count: requests.count { |r| r.verified_at.present? },
            first_seen_at:  requests.last.created_at.iso8601,
            last_seen_at:   requests.first.created_at.iso8601,
            requests: requests.map { |r|
              {
                id:              r.id,
                magnet: {
                  id:    r.lead_magnet.id,
                  slug:  r.lead_magnet.slug,
                  title: r.lead_magnet.title,
                },
                referral_source: r.referral_source,
                verified_at:     r.verified_at&.iso8601,
                created_at:      r.created_at.iso8601,
              }
            },
          }
        end

        private

        def summary_json(row)
          {
            email:          row.email,
            request_count:  row.request_count.to_i,
            verified_count: row.verified_count.to_i,
            first_seen_at:  row.first_seen_at.iso8601,
            last_seen_at:   row.last_seen_at.iso8601,
          }
        end
      end
    end
  end
end
