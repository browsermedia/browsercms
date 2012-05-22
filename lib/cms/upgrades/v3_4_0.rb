module Cms
  module Upgrades

    # Commands specifically for upgrading to version 3.4.0 of BrowserCMS
    module V3_4_0

      def generate_rails_3_4_0_migration
        generate "migration", "update_version_id_columns"
        blocks = find_custom_blocks
        migration = migration_with_name("update_version_id_columns")
        text = <<TEXT
models = %w{#{blocks.join(' ')}}
models.each do |model_name|
  standardize_version_id_column(model_name)
end
TEXT
        insert_into_file migration, text, :after => "def up\n"
        insert_into_file migration, "require 'cms/upgrades/v3_4_0'\n", :before => "class"
        insert_into_file migration, "include Cms::Upgrades::V3_4_0::SchemaStatements\n", :after => "Migration\n"
      end

      module SchemaStatements

        def standardize_version_id_column(model_name)
          rename_column(prefix("#{model_name}_versions"), "#{model_name}_id", :original_record_id) if column_exists?(prefix("#{model_name}_versions"), "#{model_name}_id")
        end
      end
    end

  end
end