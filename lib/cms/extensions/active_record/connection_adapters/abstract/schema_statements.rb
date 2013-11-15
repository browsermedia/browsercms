module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements

      # Sticks :cms_ in front of a table name.
      def cms_(table_name)
        "cms_#{table_name}"
      end

      # Create a table and its versioned counterpart. Example:
      #   create_content_table :cms_events
      #   => :cms_events
      #   => :cms_event_versions
      #
      # @param table_name [Symbol] The namespaced versioned of the content table (i.e. :cms_events or :bcms_news_articles)
      # @param options
      # @option :versioned [Boolean] false creates a non-versioned table. (Default: true)
      # @option :name [Boolean] Create a :name column in the generated table. (Default: true)
      def create_content_table(table_name, options={}, &block)
        defaults = {
            versioned: true,
            name: true
        }
        options = defaults.merge(options)

        versioned = options.delete(:versioned)
        named = options.delete(:name)

        create_table table_name, options, &block
        change_table table_name do |td|
          if versioned
            td.integer :version
            td.integer :lock_version, :default => 0
          end
          td.string :name if !column_exists?(table_name.to_sym, :name) && named
          td.boolean :published, :default => false
          td.boolean :deleted, :default => false
          td.boolean :archived, :default => false
          td.integer :created_by_id
          td.integer :updated_by_id
          td.timestamps unless column_exists?(table_name.to_sym, :created_at)
        end

        if versioned
          table_name_versioned = versioned_(table_name)
          create_table table_name_versioned, options, &block
          change_table table_name_versioned do |vt|
            vt.integer :original_record_id
            vt.integer :version
            vt.string :name if !column_exists?(table_name_versioned, :name) && named
            vt.boolean :published, :default => false
            vt.boolean :deleted, :default => false
            vt.boolean :archived, :default => false
            vt.string :version_comment
            vt.integer :created_by_id
            vt.integer :updated_by_id
            vt.timestamps unless column_exists?(table_name_versioned, :created_at)
          end
        end

      end

      def drop_content_table(table_name)
        drop_table versioned_(table_name)
        drop_table table_name
      end

      # Rename a column for both its
      def rename_content_column(table_name, old_name, new_name)
        rename_column table_name, old_name, new_name
        rename_column versioned_(table_name), old_name, new_name
      end

      # Adds a column to both the primary and versioned table. Save needing two calls.
      # This is only needed if your content block is versioned, otherwise add_column will work just fine.
      def add_content_column(table_name, column_name, type, options={})
        add_column table_name, column_name, type, options
        add_column versioned_(table_name), column_name, type, options
      end

      def remove_content_column(table_name, column_name)
        remove_column table_name, column_name
        remove_column versioned_(table_name), column_name
      end

      protected

      def versioned_(table_name)
        "#{table_name.to_s.singularize}_versions".to_sym
      end

    end
  end
end
