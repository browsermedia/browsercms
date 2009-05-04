module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
      def create_versioned_table(table_name, options={}, &block)

        #Do the primary table
        t = TableDefinition.new(self)
        t.primary_key(options[:primary_key] || Base.get_primary_key(table_name)) unless options[:id] == false

        t.integer :version
        t.integer :lock_version, :default => 0
        yield t

        # Blocks currently must have a name column, otherwise the UI fails in several places.
        # Some migrations may have already specified a name attribute, so we don't want to overwrite it here.
        t.string :name unless t[:name]

        t.boolean :published, :default => false
        t.boolean :deleted, :default => false
        t.boolean :archived, :default => false
        t.integer :created_by_id
        t.integer :updated_by_id
        t.timestamps

        
        create_table_from_definition(table_name, options, t)

        #Do the versions table
        vt = TableDefinition.new(self)
        vt.primary_key(options[:primary_key] || Base.get_primary_key(table_name)) unless options[:id] == false

        vt.integer "#{table_name.to_s.singularize}_id".to_sym
        vt.integer :version
        yield vt

        # Create implicit name column in version table as well.
        vt.string :name unless vt[:name]

        vt.boolean :published, :default => false
        vt.boolean :deleted, :default => false
        vt.boolean :archived, :default => false        
        vt.string :version_comment
        vt.integer :created_by_id
        vt.integer :updated_by_id
        vt.timestamps            
        

        
        create_table_from_definition("#{table_name.to_s.singularize}_versions".to_sym, options, vt)
        
      end   
         
      def create_table_from_definition(table_name, options, table_definition)
        if options[:force] && table_exists?(table_name)
         drop_table(table_name, options)
        end

        create_sql = "CREATE#{' TEMPORARY' if options[:temporary]} TABLE "
        create_sql << "#{quote_table_name(table_name)} ("
        create_sql << table_definition.to_sql
        create_sql << ") #{options[:options]}"
        execute create_sql            
      end
      
      def drop_versioned_table(table_name)
        drop_table "#{table_name.singularize}_versions".to_sym
        drop_table table_name
      end
      
    end
  end
end