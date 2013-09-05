class Browsercms400 < ActiveRecord::Migration

  def up
    add_column prefix(:section_nodes), :slug, :string
    add_column prefix(:dynamic_views), :path, :string
    add_column prefix(:dynamic_views), :locale, :string
    add_column prefix(:dynamic_views), :partial, :boolean
    add_column prefix(:dynamic_view_versions), :path, :string
    add_column prefix(:dynamic_view_versions), :locale, :string
    add_column prefix(:dynamic_view_versions), :partial, :boolean

    drop_table prefix(:content_type_groups)
    drop_table prefix(:content_types)
  end
end
