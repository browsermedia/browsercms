class Browsercms400 < ActiveRecord::Migration

  def up
    rename_table :section_nodes, :cms_section_nodes if table_exists?(:section_nodes) && !table_exists?(:section_nodes)
    add_column :cms_section_nodes, :slug, :string
  end
end
