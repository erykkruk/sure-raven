class AddPreferencesToUsers < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:users, :preferences)
      add_column :users, :preferences, :jsonb, default: {}, null: false
    end
    unless index_exists?(:users, :preferences)
      add_index :users, :preferences, using: :gin
    end
  end
end
