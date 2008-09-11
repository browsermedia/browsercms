class CreateHtmlBlocks < ActiveRecord::Migration
  def self.up
    create_table :html_blocks do |t|
      t.integer :version, :default => 1      
      t.string :name
      t.string :content
      t.string :status
      t.timestamps
    end
    create_table :html_block_versions do |t|
      t.integer :html_block_id
      t.string :name
      t.string :content
      t.string :status
      t.integer :version, :default => 1
      t.timestamps
    end    
  end

  def self.down
    drop_table :html_block_versions
    drop_table :html_blocks
  end
end
