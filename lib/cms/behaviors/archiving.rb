module Cms
  module Behaviors
    module Archiving
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods
        def archivable?
          !!@is_archivable
        end
        def is_archivable(options={})
          @is_archivable = true
          include InstanceMethods

          scope :archived, :conditions => {:archived => true}
          scope :not_archived, :conditions => {:archived => false}        
        end
      end
      module InstanceMethods
        def archive
          self.archived = true
          self.version_comment = "Archived"
          self.save
        end
        def archive!
          self.archived = true
          self.version_comment = "Archived"          
          self.save!
        end
        def unarchive
          self.archived = false
          self.version_comment = "Unarchived"          
          self.save
        end
        def unarchive!
          self.archived = false
          self.version_comment = "Unarchived"          
          self.save!
        end
      end
    end
  end
end
