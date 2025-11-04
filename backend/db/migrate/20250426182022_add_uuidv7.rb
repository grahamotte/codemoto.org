class AddUuidv7 < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto'
  end
end
