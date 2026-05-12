module Api
  module V1
    module Admin
      class AssessmentsController < ApplicationController
        include AdminAuthentication

        DEFAULT_PER_PAGE = 50
        MAX_PER_PAGE = 200

        def index
          scope = Assessment.recent
          scope = scope.where(archetype: params[:archetype]) if params[:archetype].present?
          scope = scope.where(created_at: parse_date(params[:from])..) if params[:from].present?
          scope = scope.where(created_at: ..parse_date(params[:to])) if params[:to].present?

          page     = [params[:page].to_i, 1].max
          per_page = [params[:per_page].to_i.nonzero? || DEFAULT_PER_PAGE, MAX_PER_PAGE].min
          total    = scope.count
          records  = scope.offset((page - 1) * per_page).limit(per_page)

          render json: {
            data: records.map { |a| serialize(a) },
            pagination: { page: page, per_page: per_page, total: total },
          }
        end

        private

        def serialize(assessment)
          {
            id:               assessment.id,
            email:            assessment.email,
            total_score:      assessment.total_score,
            archetype:        assessment.archetype,
            dimension_scores: assessment.dimension_scores,
            referral_source:  assessment.referral_source,
            created_at:       assessment.created_at.iso8601,
          }
        end

        def parse_date(str)
          Time.zone.parse(str)
        rescue ArgumentError, TypeError
          nil
        end
      end
    end
  end
end
