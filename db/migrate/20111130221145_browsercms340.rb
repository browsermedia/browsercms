# Upgrade to Browsercms v3.4.0
require 'cms/upgrades/v3_4_0'
class Browsercms340 < ActiveRecord::Migration
  include Cms::Upgrades::V3_4_0::SchemaStatements

  def change
    # Namespace class_names where they are not namespaced.
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
      Cms::AbstractFileBlock.update_all("type = '#{namespace_model(content_type)}'", "type = '#{content_type}'")
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
    namespaced_class = namespace_model(name)
    puts "Update connectors for #{name} to #{namespaced_class}"
    Cms::Connector.where(:connectable_type => name).each do |connector|
      connector.connectable_type = namespaced_class
      connector.save!
    end
  end

  def standardize_foreign_keys_from_versions_tables_to_original_table
    models = %w[attachment dynamic_view file_block html_block link page ]
    models.each do |model|
      standardize_version_id_column(model)
    end
  end
end
