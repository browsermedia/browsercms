class CreateFileBlocks < ActiveRecord::Migration
  def self.up
    create_versioned_table :file_blocks do |t|
      t.string :type
      t.integer :file_metadata_id
      t.string :file_metadata_type
      t.string :name
      t.string :status
    end
  end

  def self.down
    drop_versioned_table :file_blocks
  end
end
