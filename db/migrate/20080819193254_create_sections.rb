class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :name
      t.string :path
      t.boolean :root
      t.boolean :hidden
      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
