class EnableCitextExtension < ActiveRecord::Migration[7.2]
  def change
    enable_extension "citext"
  end
end
