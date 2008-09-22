class CreateFileBlocks < ActiveRecord::Migration
  def self.up
    create_table :file_blocks do |t|
      t.string :type
      t.integer :section_id
      t.integer :cms_file_id
      t.string :cms_file_type
      t.string :name
      t.string :status
      t.integer :version, :default => 1

      t.timestamps
    end

    create_table :file_block_versions do |t|
      t.integer :file_block_id
      t.string :type
      t.integer :section_id
      t.integer :cms_file_id
      t.string :cms_file_type
      t.string :name
      t.string :status
      t.integer :version, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :file_block_versions
    drop_table :file_blocks
  end
end
