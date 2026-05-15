module Api
  module V1
    module Admin
      module Outreel
        # Common base for the admin/outreel endpoints — wraps AdminAuthentication
        # and the same RecordNotFound / RecordInvalid handling outreel used.
        class BaseController < ApplicationController
          include AdminAuthentication

          rescue_from ActiveRecord::RecordNotFound do |e|
            render json: { error: e.message }, status: :not_found
          end

          rescue_from ActiveRecord::RecordInvalid do |e|
            render json: { errors: e.record.errors.as_json }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
