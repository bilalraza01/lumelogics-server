class EnablePgcrypto < ActiveRecord::Migration[7.2]
  def change
    # Needed so `id: :uuid` columns can default to gen_random_uuid().
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  end
end
