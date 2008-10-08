class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.string :name
      t.string :full_name
      t.string :description
      t.string :for_module

      t.timestamps
    end
    
    create_table :groups_permissions, :id => false do |t|
      t.integer :group_id
      t.integer :permission_id
    end
  end

  def self.down
    drop_table :groups_permissions
    drop_table :permissions
  end
end
