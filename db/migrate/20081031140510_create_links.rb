class CreateLinks < ActiveRecord::Migration
  def self.up
    create_versioned_table :links do |t|
      t.string :name
      t.string :url
      t.boolean :new_window, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_versioned_table :links
  end
end
