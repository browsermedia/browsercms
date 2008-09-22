class CreateCmsFiles < ActiveRecord::Migration
  def self.up
    create_table :cms_files do |t|
      t.string :type
      t.string :file_name
      t.string :file_extension
      t.string :file_type
      t.integer :file_datum_id
      t.integer :file_size
      t.integer :image_width
      t.integer :image_height
      t.integer :parent_id
      t.string :thumbnail_dimensions

      t.timestamps
    end
  end

  def self.down
    drop_table :cms_files
  end
end
