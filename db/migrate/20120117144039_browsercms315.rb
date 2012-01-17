class Browsercms315 < ActiveRecord::Migration
  def self.up
    add_column :section_nodes, :ancestry, :string
    add_index :section_nodes, :ancestry
  end

  def self.down
    remove_column :section_nodes, :ancestry
    remove_index :section_nodes, :ancestry
  end
end
