class CreatePageRoutes < ActiveRecord::Migration
  def self.up
    create_table :page_routes do |t|
      t.string :name
      t.string :pattern
      t.belongs_to :page
      t.text :code
      
      t.timestamps
    end
  end

  def self.down
    drop_table :page_routes
  end
end
