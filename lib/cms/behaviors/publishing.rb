module Cms
  module Behaviors
    module Publishing
      def self.included(model_class)
        model_class.extend(MacroMethods)
        model_class.class_eval do
          def publishable?
            false
          end
        end
      end
      module MacroMethods      
        def publishable?
          !!@is_publishable
        end
        def is_publishable(options={})
          @is_publishable = true
          extend ClassMethods
          include InstanceMethods
        
          attr_accessor :publish_on_save
          attr_accessor :published_by_page
        
          before_save :set_published
        
          named_scope :published, :conditions => {:published => true}
          named_scope :unpublished, :conditions => {:published => false}        
        end
        module ClassMethods
        end
        module InstanceMethods
          def publishable?
            if self.class.connectable?
              new_record? ? !connect_to_page_id : connected_page_count < 1
            else
              true
            end
          end
          def publish
            self.publish_on_save = true
            self.version_comment = "Published" if self.class.versioned?
            save
          end
          def publish!
            self.publish_on_save = true
            self.version_comment = "Published" if self.class.versioned?
            save!
          end
          def publish_by_page(page)
            self.published_by_page = page
            if publish
              self.published_by_page = nil          
              true
            else
              false
            end
          end
          def publish_by_page!(page)
            self.published_by_page = page
            publish!
            self.published_by_page = nil
          end
          def set_published
            self.published = !!@publish_on_save
            @publish_on_save = nil
            true
          end
          def status
            published? ? :published : :draft
          end        
          def status_name
            status.to_s.titleize
          end
          def live?
            self.class.versioned? ? versions.count(:conditions => ['version > ? AND published = ?', version, true]) == 0 && published? : true
          end        
        end
      end
    end
  end
end
