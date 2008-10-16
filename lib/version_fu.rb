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
      self.versioned_foreign_key        = options[:foreign_key] || table_name.singularize.foreign_key
      self.versioned_table_name         = options[:table_name]  || "#{table_name_prefix}#{table_name.singularize}_versions#{table_name_suffix}"
      self.version_column               = options[:version_column]    || 'version'

      # Setup versions association
      class_eval do
        has_many :versions, :class_name  => "#{self.to_s}::#{versioned_class_name}",
                            :foreign_key => versioned_foreign_key do
          def latest
            find :first, :order=>'version desc'
          end                    
        end
        
        attr_reader :new_revision_comment
        
        before_save :set_revision_comment        
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
      versioned_class.class_eval(&block) if block_given?
      
      # Finally setup which columns to version
      self.versioned_columns =  versioned_class.new.attributes.keys - 
        [versioned_class.primary_key, versioned_foreign_key, version_column, 'position', 'created_at', 'updated_at']
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
      new_version
    end
    
    def revert(user)
      revert_to(version-1, user) unless version == 1
    end
    
    def revert_to_without_save(version, user)
      raise "Version parameter missing" if version.blank?
      revert_to_version = find_version(version)
      raise "Could not find version #{version}" unless revert_to_version
      versioned_columns.each do |a|
        send("#{a}=", revert_to_version.send(a))
      end  
      self.updated_by_user = user
      self.new_revision_comment = "Reverted to version #{version}"
      self            
    end    
    
    def revert_to(version, user)
      revert_to_without_save(version, user)
      save
    end    
        
    def as_of_version(version)
      v = find_version(version)
      raise ActiveRecord::RecordNotFound.new("version #{version} does not exist for <#{self.class}:#{id}>") unless v
      obj = self.class.new
      (versioned_columns + [:version, :updated_at]).each do |a|
        obj.send("#{a}=", v.send(a))
      end
      obj.id = id
      #Need to do this so associations can be loaded
      obj.instance_variable_set("@new_record", false)
      obj      
    end
    
    def current_version?
      self.class.find(id).version == version
    end
    
    def create_new_version!
      instatiate_revision.save!
      update_without_callbacks
    end
    
    def new_revision_comment=(comment)
      revision_comment_will_change!
      @new_revision_comment = comment      
    end
    
    def set_revision_comment
      if changed?
        if @new_revision_comment.blank?
          if new_record?
            self.revision_comment = 'Created'
          else
            if create_new_version?
              changed_attributes = changes.keys-["version"]
              self.revision_comment = "#{changed_attributes.map(&:humanize).join(", ")} edited"
            end
          end
        else
          self.revision_comment = @new_revision_comment
        end
      end
    end
    
  end
end