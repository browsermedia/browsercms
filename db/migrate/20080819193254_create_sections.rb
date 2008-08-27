class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.integer :parent_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
