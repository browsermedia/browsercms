module Cms
  module Behaviors
    module Userstamping
      def userstamped?
        !!@is_userstamped
      end
      def is_userstamped
        @is_userstamped = true
        extend ClassMethods
        include InstanceMethods
        
        belongs_to :created_by, :class_name => "User"
        belongs_to :updated_by, :class_name => "User"
        
        before_save :set_userstamps
        
        named_scope :created_by, lambda{|user| {:conditions => {:created_by => user}}}        
        named_scope :updated_by, lambda{|user| {:conditions => {:updated_by => user}}}        
      end
      module ClassMethods
      end
      module InstanceMethods
        def set_userstamps
          self.created_by = User.current if new_record?
          self.updated_by = User.current
        end
      end
    end
  end
end
