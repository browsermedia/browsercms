# Upgrade to Browsercms v3.4.0
class Browsercms340 < ActiveRecord::Migration

  def change
    # Prefix the correct namespace where class_names are not prefixed
    %w[HtmlBlock Category CategoryType Portlet FileBlock ImageBlock Tag].each do |content_type|
      update_content_types(content_type)
      update_connectors_table(content_type)
    end

    update_sitemap
    update_files
    standardize_foreign_keys_from_versions_tables_to_original_table
  end


  private

  def namespace_model(name)
    "Cms::#{name}"
  end

  def update_files
    %w[FileBlock ImageBlock].each do |content_type|
      Cms::AbstractFileBlock.update_all("type = '#{prefix(content_type)}'", "type = '#{content_type}'")
    end
  end

  def update_sitemap
    %w[Section Page Link Attachment].each do |addressable|
      Cms::SectionNode.where(:node_type=>addressable).each do |node|
        node.node_type = namespace_model(addressable)
        node.save!
      end
    end
  end

  def update_content_types(name)
    found = Cms::ContentType.named(name).first
    if found
      found.name = namespace_model(name)
      found.save!
    end
  end

  def update_connectors_table(name)
    Cms::Connector.where(:connectable_type => name).each do |connector|
      connector.connectable_type = prefix(name)
      connector.save!
    end
  end

  def standardize_foreign_keys_from_versions_tables_to_original_table
    tables = %w[attachment dynamic_view file_block html_block link page ]
    tables.each do |table|
      rename_column(prefix("#{table}_versions"), "#{table}_id", :original_record_id) if column_exists?(prefix("#{table}_versions"), "#{table}_id")
    end
  end
end
