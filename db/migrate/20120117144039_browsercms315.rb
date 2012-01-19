class Browsercms315 < ActiveRecord::Migration
  def self.up
    add_column :section_nodes, :ancestry, :string
    add_index :section_nodes, :ancestry

    # Will need to build the ancestry for all section_nodes
    # Should rename table too.

    add_column :pages, :latest_version, :integer
    add_column :links, :latest_version, :integer
    # Will need to update all existing pages to have a valid value for this.
  end

  def self.down
    remove_column :links, :latest_version
    remove_column :pages, :latest_version
    remove_column :section_nodes, :ancestry
    remove_index :section_nodes, :ancestry
  end
end
