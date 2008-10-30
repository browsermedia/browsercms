class CreatePortlets < ActiveRecord::Migration
  def self.up
    create_table :portlets do |t|
      t.string :portlet_type_id
      t.string :name
      t.boolean :deleted, :default => false
      t.timestamps
    end
    
    create_table :portlet_attributes do |t|
      t.integer :portlet_id
      t.string :name
      t.string :value
    end
    
  end

  def self.down
    drop_table :portlet_attributes
    drop_table :portlets
  end
end
