module Cms
  module Acts
    module ContentObject
    
      def self.included(cls)
        cls.extend MacroMethods
      end
    
      module MacroMethods
        
        STATUSES = ["IN_PROGRESS", "PUBLISHED", "ARCHIVED", "DELETED"]
        
        def acts_as_content_block(options={})
          @statuses = STATUSES
          acts_as_content_object(options)
          include Cms::BlockSupport          
        end

        def acts_as_content_page(options={})
          @statuses = STATUSES + ["HIDDEN"]
          acts_as_content_object(options)
        end
                
        private
          def acts_as_content_object(options={})                   
            @default_status = @statuses.first      
            before_validation_on_create :set_default_status
        
            validates_inclusion_of :status, :in => @statuses
        
            define_status_query_methods
            define_status_action_methods
        
            include InstanceMethods
          end
        
          def define_status_query_methods
            @statuses.each do |status|
              define_method "#{status.underscore}?" do
                self.status == status
              end
            end        
          end        
          
          def define_status_action_methods
            {
                "PUBLISHED" => :publish,
                "ARCHIVED" => :archive,
                "IN_PROGRESS" => :in_progress,
                "DELETED" => :delete
                }.each do |status, method_name|
              define_method method_name do
                self.status = status
                save
              end
              define_method "#{method_name}!" do
                self.status = status
                save!
              end
            end                    
          end
          
      end
    
      module InstanceMethods
      
        def self.included(cls)
          cls.extend ClassMethods
        end
      
        def set_default_status
          self.status = self.class.default_status if status.blank?
        end
      
        module ClassMethods   
          def default_status
            @default_status
          end 
          def statuses
            @statuses
          end
        end
      
      end
    end
  end
end