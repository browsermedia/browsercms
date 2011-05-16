module Cms
  module Behaviors
    module Userstamping
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods      
        def userstamped?
          !!@is_userstamped
        end
        def is_userstamped(options={})
          @is_userstamped = true
          extend ClassMethods
          include InstanceMethods
        
          belongs_to :created_by, :class_name => "Cms::User"
          belongs_to :updated_by, :class_name => "Cms::User"
        
          before_save :set_userstamps
        
          scope :created_by, lambda{|user| {:conditions => {:created_by => user}}}
          scope :updated_by, lambda{|user| {:conditions => {:updated_by => user}}}        
        end
      end
      module ClassMethods
      end
      module InstanceMethods
        def set_userstamps
          current_user = Cms::User.current ? Cms::User.current : nil
          if new_record?
            self.created_by = current_user
          end
          self.updated_by = current_user

        end
      end
    end
  end
end
