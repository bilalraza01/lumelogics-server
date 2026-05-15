class CreateLeadMagnetRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :lead_magnet_requests, id: :uuid do |t|
      t.references :lead_magnet, type: :uuid, null: false, foreign_key: true

      t.string  :email,              null: false
      t.string  :verification_token, null: false
      t.datetime :verified_at

      t.string :ip_address
      t.string :user_agent
      t.string :referral_source

      t.boolean :email_sent,    null: false, default: false
      t.datetime :email_sent_at

      t.timestamps
    end

    add_index :lead_magnet_requests, :verification_token, unique: true
    add_index :lead_magnet_requests, :email
    add_index :lead_magnet_requests, :created_at
  end
end
