class Browsercms315 < ActiveRecord::Migration
  def self.up
    add_column :section_nodes, :ancestry, :string
    add_index :section_nodes, :ancestry

    # Will need to build the ancestry for all section_nodes
    # Should rename table too.
  end

  def self.down
    remove_column :section_nodes, :ancestry
    remove_index :section_nodes, :ancestry
  end
end
