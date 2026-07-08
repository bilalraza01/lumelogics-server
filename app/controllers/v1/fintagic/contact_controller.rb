module V1
  module Fintagic
    # POST /v1/fintagic/contact
    #
    # Receives a Fintagic contact-form submission, persists it as an audit
    # trail, and enqueues an email notification to Bilal via Resend.
    # Mirrors the shape of Api::V1::LeadMagnetsController#create_request.
    class ContactController < ApplicationController
      DUPLICATE_WINDOW = 1.hour

      REQUIRED_FIELDS = %i[name email company revenue message].freeze

      def create
        # Honeypot: real users don't fill hidden fields. Return the same
        # success shape so bots can't detect the trap by response diffing.
        if params[:hp].to_s.strip.present?
          return render(json: { status: "received" }, status: :ok)
        end

        payload = contact_params

        # Presence checks return the offending field so the client can
        # highlight it. Order matches the form.
        REQUIRED_FIELDS.each do |field|
          if payload[field].to_s.strip.empty?
            return render(
              json:   { error: "missing_field", field: field.to_s },
              status: :unprocessable_entity,
            )
          end
        end

        email = payload[:email].to_s.strip.downcase
        unless email.match?(URI::MailTo::EMAIL_REGEXP)
          return render(
            json:   { error: "invalid_email", field: "email" },
            status: :unprocessable_entity,
          )
        end

        # Dedupe on email within the window so a panicked double-submit
        # doesn't email Bilal twice. Idempotent from the client's POV.
        existing = ContactSubmission
                     .where(email: email)
                     .where(created_at: DUPLICATE_WINDOW.ago..)
                     .recent
                     .first

        submission = existing || ContactSubmission.create!(
          name:       payload[:name].to_s.strip,
          email:      email,
          company:    payload[:company].to_s.strip,
          website:    payload[:website].to_s.strip.presence,
          revenue:    payload[:revenue].to_s.strip,
          message:    payload[:message].to_s.strip,
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
        )

        FintagicContactEmailJob.perform_later(submission.id) unless existing

        render json: { status: "received" }, status: existing ? :ok : :created
      end

      private

      def contact_params
        params.permit(:name, :email, :company, :website, :revenue, :message, :hp)
              .to_h
              .symbolize_keys
      end
    end
  end
end
