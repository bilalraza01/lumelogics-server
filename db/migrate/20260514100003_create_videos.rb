class CreateVideos < ActiveRecord::Migration[7.2]
  def change
    create_table :videos do |t|
      t.references :prospect, null: false, foreign_key: true
      t.string :slug,     null: false
      t.string :loom_url, null: false
      t.string :r2_mp4_key
      t.string :r2_gif_key
      t.string :mp4_url
      t.string :gif_url
      t.string :player_url
      t.integer :duration_seconds
      t.string :status, null: false, default: "pending"
      t.text   :error_message
      t.integer :batch_id

      t.timestamps
    end

    add_index :videos, :slug, unique: true
    add_index :videos, :status
    add_index :videos, :batch_id
  end
end
