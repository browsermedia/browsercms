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
        
          attr_accessor :version_comment        
        
          has_many :versions, :class_name  => version_class_name, :foreign_key => version_foreign_key
        
          before_save :build_new_version      
        
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
              (%w[id lock_version position version_comment created_at updated_at created_by_id updated_by_id] + [version_foreign_key]))
          end                   
        end
        module InstanceMethods
          def build_new_version
            if build_new_version?
              increment_version            
              attrs = versioned_attributes
              attrs[:version_comment] = @version_comment || default_version_comment
              @version_comment = nil            
              new_version = versions.build(attrs)

              after_build_new_version(new_version) if respond_to?(:after_build_new_version)
            end          
            true
          end

          def build_new_version?
            !!(new_record? || !@version_comment.blank? || self.class.versioned_columns.detect{|c| __send__ "#{c}_changed?" })
          end    

          def increment_version
            self.version = version.to_i + 1
          end            

          def versioned_attributes
            self.class.versioned_columns.inject({}){|attrs, col| attrs[col] = send(col); attrs }
          end 

          def default_version_comment
            if new_record?
              "Created"
            else
              "Changed #{(changes.keys - %w[version created_by_id updated_by_id]).sort.join(', ')}"
            end
          end          

          def current_version?
            self.class.find(id).version == version
          end

          def current_version
            find_version(version)
          end    

          def find_version(number)
            versions.first(:conditions => { :version => number })
          end

          def live_version
            if self.class.publishable?    
              if published?         
                self             
              else
                live_version = versions.first(:conditions => {:published => true}, :order => "version desc, id desc")
                live_version ? as_of_version(live_version.version) : nil
              end                
            else
              self
            end
          end        


          def as_of_version(version)
            v = find_version(version)
            raise ActiveRecord::RecordNotFound.new("version #{version.inspect} does not exist for <#{self.class}:#{id}>") unless v
            obj = self.class.new

            (self.class.versioned_columns + [:version, :updated_at]).each do |a|
              obj.send("#{a}=", v.send(a))
            end
            obj.id = id
            obj.lock_version = lock_version
            
            #Need to do this so associations can be loaded
            obj.instance_variable_set("@new_record", false)

            #Callback to allow us to load other data when an older version is loaded
            obj.after_as_of_version if obj.respond_to?(:after_as_of_version)

            obj      
          end

          def revert
            revert_to(version - 1) unless version == 1
          end

          def revert_to_without_save(version)
            raise "Version parameter missing" if version.blank?
            revert_to_version = find_version(version)
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
        end
      end
    end
  end
end
