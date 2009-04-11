class CreatePageRouteOptions < ActiveRecord::Migration
  def self.up
    create_table :page_route_options do |t|
      t.belongs_to :page_route
      t.string :type
      t.string :name
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :page_route_options
  end
end
