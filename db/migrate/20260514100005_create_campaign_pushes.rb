class CreateCampaignPushes < ActiveRecord::Migration[7.2]
  def change
    create_table :campaign_pushes do |t|
      t.references :prospect, null: false, foreign_key: true
      t.references :video,    null: true,  foreign_key: true
      t.bigint :smartlead_campaign_id, null: false
      t.string :smartlead_campaign_name
      t.string :status, null: false
      t.string :skip_reason
      t.jsonb  :response_payload
      t.datetime :pushed_at

      t.timestamps
    end

    add_index :campaign_pushes, :smartlead_campaign_id
    add_index :campaign_pushes,
              %i[prospect_id smartlead_campaign_id],
              unique: true,
              where:  "status = 'success'",
              name:   "index_campaign_pushes_unique_successful_push"
  end
end
