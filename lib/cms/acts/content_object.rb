module Cms
  module Acts
    module ContentObject
    
      def self.included(cls)
        cls.extend MacroMethods
      end
    
      module MacroMethods
        def acts_as_content_object(options={})
                   
          @statuses = ["IN_PROGRESS", "PUBLISHED", "ARCHIVED", "DELETED"]
          if options[:status] == :page
            @statuses << "HIDDEN"
          else
            include Cms::BlockSupport
          end

          @default_status = @statuses.first      
          before_validation_on_create :set_default_status
        
          validates_inclusion_of :status, :in => @statuses
        
          #Create query methods like pubished?
          @statuses.each do |status|
            define_method "#{status.underscore}?" do
              self.status == status
            end
          end        
        
          #Define the action methods for each status, like publish and publish!, which set the status and call save
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
        
          include InstanceMethods
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