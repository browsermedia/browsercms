class CreateDynamicViews < ActiveRecord::Migration
  def self.up
    create_versioned_table :dynamic_views do |t|
      t.string :type
      t.string :name
      t.string :format
      t.string :handler
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_versioned_table :page_templates
  end
end
