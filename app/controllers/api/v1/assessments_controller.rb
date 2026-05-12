module Api
  module V1
    class AssessmentsController < ApplicationController
      DUPLICATE_WINDOW = 1.hour
      EXPECTED_QUESTION_IDS = (1..18).map { |i| "q#{i}" }.freeze

      def create
        validation_error = validate_payload
        return render(json: { error: validation_error }, status: :unprocessable_entity) if validation_error

        # If the same email already submitted within DUPLICATE_WINDOW, return
        # the existing record without re-scoring or re-sending the email.
        existing = Assessment
                   .where(email: assessment_params[:email].downcase)
                   .where(created_at: DUPLICATE_WINDOW.ago..)
                   .recent
                   .first
        return render_result(existing, status: :ok) if existing

        result = AssessmentScorer.new(assessment_params[:answers]).call

        assessment = Assessment.create!(
          email:            assessment_params[:email].downcase,
          answers:          assessment_params[:answers],
          dimension_scores: result.dimension_scores,
          total_score:      result.total_score,
          archetype:        result.archetype,
          referral_source:  assessment_params[:referral_source],
          ip_address:       request.remote_ip,
          user_agent:       request.user_agent,
        )

        AssessmentEmailJob.perform_later(assessment.id)

        render_result(assessment, status: :created)
      end

      def show
        assessment = Assessment.find_by(result_token: params[:token])
        return render(json: { error: "not_found" }, status: :not_found) unless assessment

        render_result(assessment, status: :ok)
      end

      private

      def assessment_params
        @assessment_params ||= params
          .permit(:email, :referral_source, answers: EXPECTED_QUESTION_IDS)
          .to_h
          .symbolize_keys
      end

      def validate_payload
        email = assessment_params[:email].to_s.strip
        return "invalid_email" unless email.match?(URI::MailTo::EMAIL_REGEXP)

        answers = assessment_params[:answers]
        return "missing_answers" unless answers.is_a?(Hash)
        return "missing_answers" unless (EXPECTED_QUESTION_IDS - answers.keys.map(&:to_s)).empty?
        return "missing_answers" unless answers.keys.size == EXPECTED_QUESTION_IDS.size
        return "invalid_answer_values" unless answers.values.all? { |v| v.is_a?(Integer) && v.between?(0, 5) }

        nil
      end

      def render_result(assessment, status:)
        meta = ArchetypeMeta.for(assessment.archetype)

        render json: {
          result_token:      assessment.result_token,
          total_score:       assessment.total_score,
          archetype:         assessment.archetype,
          archetype_display: meta[:display],
          verdict:           meta[:verdict],
          dimension_scores:  assessment.dimension_scores,
          cta:               meta[:cta],
          results_url:       results_url_for(assessment),
        }, status: status
      end

      def results_url_for(assessment)
        base = ENV.fetch("FRONTEND_URL", "https://lumelogics.com")
        "#{base}/free-assessment/results/#{assessment.result_token}"
      end
    end
  end
end
