class CreateContactSubmissions < ActiveRecord::Migration[7.2]
  def change
    create_table :contact_submissions, id: :uuid do |t|
      t.string :name,    null: false
      t.string :email,   null: false
      t.string :company, null: false
      t.string :website
      t.string :revenue, null: false
      t.text   :message, null: false

      t.string :ip_address
      t.string :user_agent

      t.boolean  :email_sent,    null: false, default: false
      t.datetime :email_sent_at

      t.timestamps
    end

    add_index :contact_submissions, :email
    add_index :contact_submissions, :created_at
  end
end
