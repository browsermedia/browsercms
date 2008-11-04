class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.string :code
      t.integer :group_type_id
      t.timestamps
    end
    
    create_table :user_group_memberships do |t|
      t.integer :user_id
      t.integer :group_id
    end
  end

  def self.down
    drop_table :user_group_memberships
    drop_table :groups
  end
end
