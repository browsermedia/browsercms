class Browsercms400 < ActiveRecord::Migration

  def up
    rename_table :section_nodes, :cms_section_nodes if table_exists?(:section_nodes) && !table_exists?(:section_nodes)

    add_content_column prefix(:html_blocks), :path, :string
  end
end
