class CreateActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :activities do |t|
      t.references :prospect, null: false, foreign_key: true
      t.string :event_type, null: false
      t.jsonb  :metadata,   default: {}, null: false
      t.datetime :occurred_at, null: false

      t.datetime :created_at, null: false
    end

    add_index :activities, %i[prospect_id occurred_at], order: { occurred_at: :desc }
    add_index :activities, :event_type
  end
end
