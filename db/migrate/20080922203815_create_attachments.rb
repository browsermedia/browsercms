class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_versioned_table :attachments do |t|
      t.string :file_path
      t.string :file_location
      t.string :file_extension
      t.string :file_type
      t.integer :file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
