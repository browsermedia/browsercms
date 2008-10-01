module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements
      def create_versioned_table(table_name, options={}, &block)

        #Do the primary table
        t = TableDefinition.new(self)
        t.primary_key(options[:primary_key] || Base.get_primary_key(table_name)) unless options[:id] == false

        t.integer :version, :default => 1
        yield t
        t.timestamps
        t.integer :updated_by_id
        t.string :revision_comment
        
        create_table_from_definition(table_name, options, t)

        #Do the versions table
        vt = TableDefinition.new(self)
        vt.primary_key(options[:primary_key] || Base.get_primary_key(table_name)) unless options[:id] == false

        vt.integer "#{table_name.singularize}_id".to_sym
        vt.integer :version, :default => 1
        yield vt    
        vt.timestamps            
        vt.integer :updated_by_id
        vt.string :revision_comment
        
        create_table_from_definition("#{table_name.singularize}_versions".to_sym, options, vt)
        
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