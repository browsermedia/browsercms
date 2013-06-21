class Browsercms400 < ActiveRecord::Migration

  def up
    rename_table :section_nodes, :cms_section_nodes if table_exists?(:section_nodes) && !table_exists?(:section_nodes)
    add_column :cms_section_nodes, :slug, :string
    add_column :cms_dynamic_views, :path, :string
    add_column :cms_dynamic_views, :locale, :string
    add_column :cms_dynamic_views, :partial, :boolean
    add_column :cms_dynamic_view_versions, :path, :string
    add_column :cms_dynamic_view_versions, :locale, :string 
    add_column :cms_dynamic_view_versions, :partial, :boolean
  end
end
