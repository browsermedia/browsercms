module Cms
  module Behaviors
    module Hiding
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods
        def hideable?
          !!@is_hideable
        end
        def is_hideable(options={})
          @is_hideable = true
          extend ClassMethods
          include InstanceMethods
        
          scope :hidden, :conditions => {:hidden => true}
          scope :not_hidden, :conditions => {:hidden => false}        
        end
      end
      module ClassMethods
      end
      module InstanceMethods
        def hide
          self.hidden = true
          self.version_comment = "Hidden"         
          self.save
        end
        def hide!
          self.hidden = true
          self.version_comment = "Hidden"
          self.save!
        end
        def unhide
          self.hidden = false
          self.version_comment = "Unhidden"          
          self.save
        end
        def unhide!
          self.hidden = false
          self.version_comment = "Unhidden"          
          self.save!
        end
      end
    end
  end
end
