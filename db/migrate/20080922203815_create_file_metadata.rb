class CreateFileMetadata < ActiveRecord::Migration
  def self.up
    create_table :file_metadata do |t|
      t.string :file_name
      t.string :file_extension
      t.string :file_type
      t.integer :file_binary_data_id
      t.integer :file_size
      t.integer :image_width
      t.integer :image_height
      t.integer :parent_id
      t.string :thumbnail_dimensions
      t.integer :section_id
      t.timestamps
    end
  end

  def self.down
    drop_table :file_metadata
  end
end
