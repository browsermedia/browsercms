#This is a Monkey Patch against Rails 2.1 that allows for migrations to be specified in multiple places
#The Rails core team doesn't like this idea, Pratik (a.k.a lifo) specifically, but there is an open ticket to see this added to rails:
#http://rails.lighthouseapp.com/projects/8994/tickets/1039-add-ability-to-specify-addtional-paths-for-migrations
#Until it does get added, we have this fragile monkey patch
module ActiveRecord
  class Migrator
    class << self
      
      def additional_migration_paths
        @additional_migration_paths ||= []  
      end
      
      def add_path(path)
        additional_migration_paths << path
      end
    
    end
  end
  
  def initialize(direction, migrations_path, target_version = nil)
    raise StandardError.new("This database does not yet support migrations") unless Base.connection.supports_migrations?
    Base.connection.initialize_schema_migrations_table
    @direction, @migrations_path, @target_version = direction, [migrations_path] + self.class.additional_migration_paths, target_version            
  end  
  
  def migrations
    @migrations ||= begin
      files = Dir[*@migrations_path.map{|e| "#{e}/[0-9]*_*.rb"}].map{|f| File.expand_path(f)}.uniq
      migrations = files.inject([]) do |klasses, file|
        version, name = file.scan(/([0-9]+)_([_a-z0-9]*).rb/).first
        
        raise IllegalMigrationNameError.new(file) unless version
        version = version.to_i
        
        if klasses.detect { |m| m.version == version }
          raise DuplicateMigrationVersionError.new(version) 
        end

        if klasses.detect { |m| m.name == name.camelize }
          raise DuplicateMigrationNameError.new(name.camelize) 
        end
        
        load(file)
        
        klasses << returning(name.camelize.constantize) do |klass|
          class << klass; attr_accessor :version end
          klass.version = version
        end
      end
      
      migrations = migrations.sort_by(&:version)
      down? ? migrations.reverse : migrations
    end
  end  
  
end