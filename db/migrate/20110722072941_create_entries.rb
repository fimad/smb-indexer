class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.integer :server_id
      t.integer :parent_id
      t.string :size
      t.string :path
      t.string :name
      t.string :search_name
      t.string :extension
      t.boolean :folder
      t.timestamp :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
