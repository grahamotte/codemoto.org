class AddUuidv7 < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  end

  def down
    disable_extension "pgcrypto" if extension_enabled?("pgcrypto")
  end
end
