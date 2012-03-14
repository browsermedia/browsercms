module Cms
  module Commands

    # Commands specifically for upgrading to version 3.4.0 of BrowserCMS
    module V3_4_0

      def generate_rails_3_4_0_migration
        generate "migration", "update_version_id_columns"
        blocks = find_custom_blocks
        migration = migration_with_name("update_version_id_columns")
        text = <<TEXT
models = %w{#{blocks.join(' ')}}
models.each do |table|
  rename_column(prefix("\#{table}_versions"), "\#{table}_id", :original_record_id) if column_exists?(prefix("\#{table}_versions"), "\#{table}_id")
end
TEXT
        inject_into_file migration, text, :after=>"def up\n"

      end
    end
  end
end