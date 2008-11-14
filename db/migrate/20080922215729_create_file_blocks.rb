class CreateFileBlocks < ActiveRecord::Migration
  def self.up
    create_versioned_table :file_blocks do |t|
      t.string :type
      t.string :name
      t.integer :attachment_id
      t.integer :attachment_version
    end
    ContentType.create!(:name => "FileBlock")
    ContentType.create!(:name => "ImageBlock")        
  end

  def self.down
    drop_versioned_table :file_blocks
  end
end
