module VersionFu
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def version_fu(options={}, &block)
      return if self.included_modules.include? VersionFu::InstanceMethods
      __send__ :include, VersionFu::InstanceMethods

      cattr_accessor :versioned_class_name, :versioned_foreign_key, :versioned_table_name, 
                     :version_column, :versioned_columns

      self.versioned_class_name         = options[:class_name]  || 'Version'
      self.versioned_foreign_key        = options[:foreign_key] || self.to_s.foreign_key
      self.versioned_table_name         = options[:table_name]  || "#{table_name_prefix}#{base_class.name.demodulize.underscore}_versions#{table_name_suffix}"
      self.version_column               = options[:version_column]    || 'version'

      # Setup versions association
      class_eval do
        has_many :versions, :class_name  => "#{self.to_s}::#{versioned_class_name}",
                            :foreign_key => versioned_foreign_key,
                            :dependent   => :destroy do
          def latest
            find :first, :order=>'version desc'
          end                    
        end

        before_save :check_for_new_version
      end
      
      # Versioned Model
      const_set(versioned_class_name, Class.new(ActiveRecord::Base)).class_eval do
        # find first version before the given version
        def self.before(version)
          find :first, :order => 'version desc',
            :conditions => ["#{original_class.versioned_foreign_key} = ? and version < ?", version.send(original_class.versioned_foreign_key), version.version]
        end

        # find first version after the given version.
        def self.after(version)
          find :first, :order => 'version',
            :conditions => ["#{original_class.versioned_foreign_key} = ? and version > ?", version.send(original_class.versioned_foreign_key), version.version]
        end

        def previous
          self.class.before(self)
        end

        def next
          self.class.after(self)
        end
      end

      # Housekeeping on versioned class
      versioned_class.cattr_accessor :original_class
      versioned_class.original_class = self
      versioned_class.set_table_name versioned_table_name
      
      # Version parent association
      versioned_class.belongs_to self.to_s.demodulize.underscore.to_sym, 
        :class_name  => "::#{self.to_s}", 
        :foreign_key => versioned_foreign_key
      
      # Block extension
      versioned_class.class_eval &block if block_given?
      
      # Finally setup which columns to version
      self.versioned_columns =  versioned_class.new.attributes.keys - 
        [versioned_class.primary_key, versioned_foreign_key, version_column, 'created_at', 'updated_at']
    end
    
    def versioned_class
      const_get versioned_class_name
    end
  end


  module InstanceMethods
    def find_version(number)
      versions.find :first, :conditions=>{:version=>number}
    end
    
    def check_for_new_version
      instatiate_revision if create_new_version?
      true # Never halt save
    end
    
    # This the method to override if you want to have more control over when to version
    def create_new_version?
      # Any versioned column changed?
      self.class.versioned_columns.detect {|a| __send__ "#{a}_changed?"}
    end
    
    def instatiate_revision
      new_version = versions.build
      versioned_columns.each do |attribute|
        new_version.__send__ "#{attribute}=", __send__(attribute)
      end
      version_number = new_record? ? 1 : version + 1
      new_version.version = version_number
      self.version = version_number
    end
  end
end