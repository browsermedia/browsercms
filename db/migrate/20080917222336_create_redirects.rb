class CreateRedirects < ActiveRecord::Migration
  def self.up
    create_table :redirects do |t|
      t.string :from_path
      t.string :to_path

      t.timestamps
    end
  end

  def self.down
    drop_table :redirects
  end
end
