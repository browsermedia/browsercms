class CreateGroupsSections < ActiveRecord::Migration
  def self.up    
    create_table :groups_sections, :id => false do |t|
      t.integer :group_id
      t.integer :section_id
    end
  end

  def self.down
    drop_table :groups_sections
  end
end
