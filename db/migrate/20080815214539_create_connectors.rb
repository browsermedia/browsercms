class CreateConnectors < ActiveRecord::Migration
  def self.up
    create_table :connectors do |t|
      t.integer :page_id
      t.string :container
      t.integer :content_block_id
      t.string :content_block_type
      t.string :position

      t.timestamps
      
    end
  end

  def self.down
    drop_table :connectors
  end
end
