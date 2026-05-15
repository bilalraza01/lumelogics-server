class CreateSmartleadCampaigns < ActiveRecord::Migration[7.2]
  def change
    create_table :smartlead_campaigns do |t|
      t.bigint :smartlead_id, null: false
      t.string :name
      t.string :status
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :smartlead_campaigns, :smartlead_id, unique: true
  end
end
