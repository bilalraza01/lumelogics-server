class CreateAudits < ActiveRecord::Migration[7.2]
  def change
    create_table :audits do |t|
      t.string :slug,         null: false
      t.string :client_name,  null: false
      t.string :industry
      t.string :status,       null: false, default: "in_progress"
      t.date   :started_on
      t.date   :completed_on
      t.jsonb  :content,      null: false, default: {}

      t.timestamps
    end

    add_index :audits, :slug, unique: true
    add_index :audits, :status
  end
end
