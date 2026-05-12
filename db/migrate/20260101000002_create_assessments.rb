class CreateAssessments < ActiveRecord::Migration[7.2]
  def change
    create_table :assessments, id: :uuid do |t|
      t.string  :result_token,     null: false
      t.string  :email,            null: false
      t.jsonb   :answers,          null: false, default: {}
      t.jsonb   :dimension_scores, null: false, default: {}
      t.integer :total_score,      null: false
      t.string  :archetype,        null: false
      t.string  :referral_source
      t.string  :ip_address
      t.string  :user_agent
      t.boolean :email_sent,       null: false, default: false
      t.datetime :email_sent_at

      t.timestamps
    end

    add_index :assessments, :result_token, unique: true
    add_index :assessments, :email
    add_index :assessments, :archetype
    add_index :assessments, :created_at
  end
end
