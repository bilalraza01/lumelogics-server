class SmartleadCampaign < ApplicationRecord
  validates :smartlead_id, presence: true, uniqueness: true
end
