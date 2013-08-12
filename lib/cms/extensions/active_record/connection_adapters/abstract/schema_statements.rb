module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements

      # Applies the current CMS prefix to the given table name.
      # Useful for where you need CMS related migrations using stock rails migrations (like add_index or create_table)
      # but still want to dynamically apply the CMS prefixes.
      def prefix(table_name)
        Cms::Namespacing.prefixed_table_name(table_name)
      end

      # Pass in ":versioned => false" in the options hash to create a non-versioned table.
      #
      # @param table_name
      # @param options
      # @option :prefix [Boolean]
      def create_content_table(table_name, options={}, &block)
        defaults = {
            versioned: true,
            prefix: true
        }
        options = defaults.merge(options)

        versioned = options.delete(:versioned)
        prefixed = options.delete(:prefix)

        if prefixed
          table_name = Cms::Namespacing.prefixed_table_name(table_name)
        end

        create_table table_name, options, &block
        change_table table_name do |td|
          if versioned
            td.integer :version
            td.integer :lock_version, :default => 0
          end
          td.string :name unless column_exists?(table_name.to_sym, :name)
          td.boolean :published, :default => false
          td.boolean :deleted, :default => false
          td.boolean :archived, :default => false
          td.integer :created_by_id
          td.integer :updated_by_id
          td.timestamps unless column_exists?(table_name.to_sym, :created_at)
        end

        if versioned
          versioned_table_name = "#{table_name.to_s.singularize}_versions"
          create_table versioned_table_name, options, &block
          change_table versioned_table_name do |vt|
            vt.integer :original_record_id
            vt.integer :version
            vt.string :name unless column_exists?(versioned_table_name.to_sym, :name)
            vt.boolean :published, :default => false
            vt.boolean :deleted, :default => false
            vt.boolean :archived, :default => false
            vt.string :version_comment
            vt.integer :created_by_id
            vt.integer :updated_by_id
            vt.timestamps unless column_exists?(versioned_table_name.to_sym, :created_at)
          end
        end

      end

      #
      # @deprecated - create_versioned_table should be considered deprecated and may be removed in a future version.
      # Use create_content_table instead in your migrations
      #
      alias :create_versioned_table :create_content_table

      def drop_versioned_table(table_name)
        table_name = Cms::Namespacing.prefixed_table_name(table_name)
        drop_table "#{table_name.singularize}_versions".to_sym
        drop_table table_name
      end

      alias :drop_content_table :drop_versioned_table

      # Rename a column for both its
      def rename_content_column(table_name, old_name, new_name)
        rename_column table_name, old_name, new_name
        rename_column version_table_name(table_name), old_name, new_name
      end

      # Adds a column to both the primary and versioned table. Save needing two calls.
      # This is only needed if your content block is versioned, otherwise add_column will work just fine.
      def add_content_column(table_name, column_name, type, options={})
        add_column table_name, column_name, type, options
        add_column version_table_name(table_name), column_name, type, options
      end

      def remove_content_column(table_name, column_name)
        remove_column table_name, column_name
        remove_column version_table_name(table_name), column_name
      end

      # Will namespace the content table
      def content_table_exists?(table_name)
        table_exists?(Cms::Namespacing.prefixed_table_name(table_name))
      end

      private

      def version_table_name(table_name)
        "#{table_name.to_s.singularize}_versions".to_sym
      end

    end
  end
end
