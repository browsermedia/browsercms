class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.string :code
      t.string :group_type
      t.timestamps
    end
    
    create_table :groups_users, :id => false do |t|
      t.integer :user_id
      t.integer :group_id
    end
  end

  def self.down
    drop_table :groups_users
    drop_table :groups
  end
end
