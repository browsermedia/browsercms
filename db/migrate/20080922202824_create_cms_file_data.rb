class CreateCmsFileData < ActiveRecord::Migration
  def self.up
    create_table :cms_file_data do |t|
      t.binary :data

      t.timestamps
    end
  end

  def self.down
    drop_table :cms_file_data
  end
end
