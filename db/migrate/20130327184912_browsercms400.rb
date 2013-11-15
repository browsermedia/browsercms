class Browsercms400 < ActiveRecord::Migration

  def up
    add_column prefix(:section_nodes), :slug, :string
    add_content_column prefix(:dynamic_views), :path, :string
    add_content_column prefix(:dynamic_views), :locale, :string, default: 'en'
    add_content_column prefix(:dynamic_views), :partial, :boolean, default: false

    drop_table prefix(:content_type_groups)
    drop_table prefix(:content_types)
  end
end
