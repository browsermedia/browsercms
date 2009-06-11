module Cms
  module Behaviors
    module Versioning
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods      
        def versioned?
          !!@is_versioned
        end
        def is_versioned(options={})
          @is_versioned = true

          @version_foreign_key = (options[:version_foreign_key] || "#{name.underscore}_id").to_s
          @version_table_name = (options[:version_table_name] || "#{table_name.singularize}_versions").to_s

          extend ClassMethods
          include InstanceMethods

          has_many :versions, :class_name  => version_class_name, :foreign_key => version_foreign_key

          before_validation_on_create :initialize_version

          attr_accessor :revert_to_version

          #Define the version class
          const_set("Version", Class.new(ActiveRecord::Base)).class_eval do 
            class << self; attr_accessor :versioned_class end

            def versioned_class
              self.class.versioned_class
            end
            def versioned_object_id
              send("#{versioned_class.name.underscore}_id")
            end
            def versioned_object
              send(versioned_class.name.underscore.to_sym)
            end                 
          end

          version_class.versioned_class = self

          version_class.belongs_to(name.underscore.to_sym, :foreign_key => version_foreign_key)

          version_class.is_userstamped if userstamped?

        end
      end
      module ClassMethods        
        def version_class
          const_get "Version"
        end

        def version_class_name
          "#{name}::Version"
        end        

        def version_foreign_key
          @version_foreign_key
        end

        def version_table_name        
          @version_table_name
        end

        def versioned_columns
          @versioned_columns ||= (version_class.new.attributes.keys - 
            (%w[id lock_version position version_comment created_at updated_at created_by_id updated_by_id type] + [version_foreign_key]))
        end                   
      end
      module InstanceMethods
        def initialize_version
          self.version = 1
        end

        def build_new_version
          # First get the values from the draft
          attrs = draft_attributes

          # Now overwrite any changed values      
          self.class.versioned_columns.each do |col|
            if(send("#{col}_changed?"))
              attrs[col] = send(col)
            end
          end

          attrs[:version_comment] = @version_comment || default_version_comment
          @version_comment = nil            
          new_version = versions.build(attrs)
          new_version.version = new_record? ? 1 : (draft.version.to_i + 1)
          after_build_new_version(new_version) if respond_to?(:after_build_new_version)
          new_version
        end

        def draft_attributes
          # When there is no draft, we'll just copy the attibutes from this object
          # Otherwise we need to use the draft
          d = new_record? ? self : draft
          self.class.versioned_columns.inject({}){|attrs, col| attrs[col] = d.send(col); attrs }
        end 

        def default_version_comment
          if new_record?
            "Created"
          else
            "Changed #{(changes.keys - %w[version created_by_id updated_by_id]).sort.join(', ')}"
          end
        end

        def save(perform_validations=true)
          transaction do
            #logger.info "..... Calling valid?"
            return false unless valid?            
            
            if changed?
              #logger.info "..... Changes => #{changes.inspect}"
            else
              #logger.info "..... No Changes"
              return true
            end
            
            #logger.info "..... Calling before_save"
            return false if callback(:before_save) == false

            if new_record?
              #logger.info "..... Calling before_create"
              return false if callback(:before_create) == false
            else      
              #logger.info "..... Calling before_update"
              return false if callback(:before_update) == false
            end

            #logger.info "..... Calling build_new_version"
            new_version = build_new_version
            #logger.info "..... Is new version valid? #{new_version.valid?}"
            if new_record?
              self.version = 1
              #logger.info "..... Calling create_without_callbacks"
              if result = create_without_callbacks
                #logger.info "..... Calling after_create"
                if callback(:after_create) != false
                  #logger.info "..... Calling after_save"
                  callback(:after_save)
                end
                
                if @publish_on_save
                  publish
                  @publish_on_save = nil
                end                
                changed_attributes.clear                                   
              end
              result
            elsif new_version
              #logger.info "..... Calling save"
              if result = new_version.save
                #logger.info "..... Calling after_save"
                if callback(:after_update) != false
                  #logger.info "..... Calling after_update"
                  callback(:after_save)
                end
                
                if @publish_on_save
                  publish
                  @publish_on_save = nil
                end 
                changed_attributes.clear
              end
              result
            end
            true
          end
        end

        def save!(perform_validations=true)
          save || raise(ActiveRecord::RecordNotSaved.new(errors.full_messages))
        end

        def draft
          versions.first(:order => "version desc")    
        end
        
        def draft_version?
          version == draft.version
        end
        
        def live_version
          find_version(self.class.find(id).version)
        end

        def live_version?
          version == self.class.find(id).version
        end

        def current_version
          find_version(self.version)
        end
        
        def find_version(number)
          versions.first(:conditions => { :version => number })
        end

        def as_of_draft_version
          as_of_version(draft.version)
        end

        def as_of_version(version)
          v = find_version(version)
          raise ActiveRecord::RecordNotFound.new("version #{version.inspect} does not exist for <#{self.class}:#{id}>") unless v
          obj = self.class.new

          (self.class.versioned_columns + [:version, :created_at, :created_by_id, :updated_at, :updated_by_id]).each do |a|
            obj.send("#{a}=", v.send(a))
          end
          obj.id = id
          obj.lock_version = lock_version

          # Need to do this so associations can be loaded
          obj.instance_variable_set("@new_record", false)

          # Callback to allow us to load other data when an older version is loaded
          obj.after_as_of_version if obj.respond_to?(:after_as_of_version)

          # Last but not least, clear the changed attributes
          if changed_attrs = obj.send(:changed_attributes)
            changed_attrs.clear
          end

          obj      
        end

        def revert
          draft_version = draft.version
          revert_to(draft_version - 1) unless draft_version == 1
        end

        def revert_to_without_save(version)
          raise "Version parameter missing" if version.blank?
          self.revert_to_version = find_version(version)
          raise "Could not find version #{version}" unless revert_to_version
          (self.class.versioned_columns - ["version"]).each do |a|
            send("#{a}=", revert_to_version.send(a))
          end  
          self.version_comment = "Reverted to version #{version}"
          self            
        end    

        def revert_to(version)
          revert_to_without_save(version)
          save
        end    

        def version_comment
          @version_comment
        end

        def version_comment=(version_comment)
          @version_comment = version_comment
          send(:changed_attributes)["version_comment"] = @version_comment
        end

      end
    end

  end
end
