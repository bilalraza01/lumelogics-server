module Api
  module V1
    module Admin
      module Outreel
        class ActivitiesController < BaseController
          def index
            prospect = Prospect.find(params[:prospect_id])
            activities = prospect.activities.recent.limit(50)
            render json: activities.map(&:as_json)
          end
        end
      end
    end
  end
end
