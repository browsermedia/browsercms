class CreateFileBlocks < ActiveRecord::Migration
  def self.up
    create_versioned_table :file_blocks do |t|
      t.string :type
      t.integer :attachment_id
      t.string :attachment_type
      t.string :name
    end
  end

  def self.down
    drop_versioned_table :file_blocks
  end
end
