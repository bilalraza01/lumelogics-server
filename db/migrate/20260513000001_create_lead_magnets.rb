class CreateLeadMagnets < ActiveRecord::Migration[7.2]
  def change
    create_table :lead_magnets, id: :uuid do |t|
      t.string :slug,           null: false
      t.string :title,          null: false
      t.text   :description

      # pdf | google_doc | google_sheet | external_url
      t.string :resource_type,  null: false
      t.string :resource_url,   null: false

      # Verification email copy
      t.string :email_subject,  null: false
      t.text   :email_intro

      # VSL section on the landing page (all optional)
      t.string :vsl_video_url
      t.string :vsl_headline
      t.text   :vsl_body

      # Falls back to a global default in the model when blank.
      t.string :calendly_url

      t.timestamps
    end

    add_index :lead_magnets, :slug, unique: true
  end
end
