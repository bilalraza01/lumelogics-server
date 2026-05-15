module Api
  module V1
    module Admin
      module Outreel
        class BatchesController < BaseController
          SLOTS_TOTAL = 25
          LOOKBACK    = 7.days

          def current
            recent     = Video.where("created_at >= ?", LOOKBACK.ago)
            batch_id   = recent.maximum(:batch_id) || 1
            slots_used = Video.where(batch_id: batch_id).count

            render json: { batch_id: batch_id, slots_used: slots_used, slots_total: SLOTS_TOTAL }
          end

          def new
            max_existing = Video.maximum(:batch_id) || 0
            new_batch_id = max_existing + 1
            render json: { batch_id: new_batch_id, slots_used: 0, slots_total: SLOTS_TOTAL }
          end
        end
      end
    end
  end
end
