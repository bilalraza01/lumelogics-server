class CreateProspects < ActiveRecord::Migration[7.2]
  def change
    create_table :prospects do |t|
      t.column :email, :citext, null: false
      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.string :linkedin_url
      t.string :website
      t.text   :notes
      t.string :status, null: false, default: "not_contacted"
      t.integer :batch_id

      t.timestamps
    end

    add_index :prospects, :email,    unique: true
    add_index :prospects, :status
    add_index :prospects, :batch_id
  end
end
