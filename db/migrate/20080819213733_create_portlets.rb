class CreatePortlets < ActiveRecord::Migration
  def self.up
    create_table :portlets do |t|
      t.string :type
      t.string :name
      t.boolean :archived, :default => false      
      t.boolean :deleted, :default => false
      t.integer :created_by_id, :updated_by_id
      t.timestamps
    end
    
    create_table :portlet_attributes do |t|
      t.integer :portlet_id
      t.string :name
      t.text :value
    end
    ContentType.create!(:name => "Portlet", :group_name => "Core", :priority => 1)
    
  end

  def self.down
    drop_table :portlet_attributes
    drop_table :portlets
  end
end
