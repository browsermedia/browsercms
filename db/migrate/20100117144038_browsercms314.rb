require 'cms/upgrades/v3_4_0'

# Retroactively fix for changes that were merged into 3.1.5/3.3.0/3.4.0. 
# This originally was for 3.4.0, but needs to be run prior to 3.1.5 migrations.
class Browsercms314 < ActiveRecord::Migration
  include Cms::Upgrades::V3_4_0::SchemaStatements
  
  def change
    standardize_foreign_keys_from_versions_tables_to_original_table
    
  end
  
  private
  def standardize_foreign_keys_from_versions_tables_to_original_table
    models = %w[attachment dynamic_view file_block html_block link page ]
    models.each do |model|
      standardize_version_id_column(model)
    end
  end
end
