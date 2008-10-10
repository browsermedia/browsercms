class CreateGroupSections < ActiveRecord::Migration
  def self.up    
    create_table :group_sections do |t|
      t.integer :group_id
      t.integer :section_id
    end
  end

  def self.down
    drop_table :group_sections
  end
end
