class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.string :name
      t.string :full_name
      t.string :description
      t.string :for_module

      t.timestamps
    end
    
    create_table :group_permissions do |t|
      t.integer :group_id
      t.integer :permission_id
    end

    create_table :group_type_permissions do |t|
      t.integer :group_type_id
      t.integer :permission_id
    end
  end

  def self.down
    drop_table :group_type_permissions
    drop_table :group_permissions
    drop_table :permissions
  end
end
