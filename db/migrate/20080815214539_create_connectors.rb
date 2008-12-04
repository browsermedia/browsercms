class CreateConnectors < ActiveRecord::Migration
  def self.up
    create_table :connectors do |t|
      t.integer :page_id
      t.integer :page_version
      t.integer :connectable_id
      t.string :connectable_type
      t.integer :connectable_version
      t.string :container
      t.integer :position
      t.timestamps
      
    end
  end

  def self.down
    drop_table :connectors
  end
end
