class CreateFileBinaryData < ActiveRecord::Migration
  def self.up
    create_table :file_binary_data do |t|
      t.binary :data

      t.timestamps
    end
  end

  def self.down
    drop_table :file_binary_data
  end
end
