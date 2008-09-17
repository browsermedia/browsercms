class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :name
      t.integer :parent_id
      t.integer :position
      t.text :path
      t.string :nav_image
      t.string :nav_rollover_image
      t.string :current_nav_image
      t.boolean :hide_from_menus
      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
