class AddFileSupportToLeadMagnets < ActiveRecord::Migration[7.2]
  def up
    add_column :lead_magnets, :resource_file, :string

    # Uploaded-file magnets (pdf / file) have no resource_url, so it can no
    # longer be NOT NULL. Conditional presence is enforced in the model.
    change_column_null :lead_magnets, :resource_url, true

    # Google Doc and Google Sheet are architecturally identical (a Google
    # share URL opened in a new tab). Collapse to a single google_doc type.
    execute <<~SQL
      UPDATE lead_magnets SET resource_type = 'google_doc'
      WHERE resource_type = 'google_sheet'
    SQL
  end

  def down
    remove_column :lead_magnets, :resource_file
    change_column_null :lead_magnets, :resource_url, false
  end
end
