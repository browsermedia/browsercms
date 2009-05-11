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
        
          after_save :publish_for_non_versioned
        
          named_scope :published, :conditions => {:published => true}
          named_scope :unpublished, :conditions => {:published => false}        
        end
      end
      module ClassMethods
      end
      module InstanceMethods
        def publishable?
          if self.class.connectable?
            new_record? ? connect_to_page_id.blank? : connected_page_count < 1
          else
            true
          end
        end
        
        def publish_for_non_versioned
          unless self.class.versioned?
            if @publish_on_save
              publish
              @publish_on_save = nil
            end
          end
        end
        
        def publish
          publish!
          true
        rescue Exception => e
          logger.warn("Could not publish, #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
          false
        end
        
        def publish!
          if new_record?
            self.publish_on_save = true
            save!
          else
            transaction do
              if self.class.versioned?
                d = draft

                # We only need to publish if this isn't already published
                # or the draft version is greater than the live version
                if !self.published? || d.version > self.version
                  
                  d.update_attributes(:published => true)

                  # copy values from the draft to the main record
                  quoted_attributes = d.send(:attributes_with_quotes, false, false, self.class.versioned_columns)

                  # Doing the SQL ourselves to avoid callbacks
                  connection.update(
                    "UPDATE #{self.class.quoted_table_name} " +
                    "SET #{quoted_comma_pair_list(connection, quoted_attributes)} " +
                    "WHERE #{connection.quote_column_name(self.class.primary_key)} = #{quote_value(id)}",
                    "#{self.class.name} Publish"
                  )
                end
              else
                connection.update(
                  "UPDATE #{self.class.quoted_table_name} " +
                  "SET published = #{connection.quote(true, self.class.columns_hash["published"])} " +
                  "WHERE #{connection.quote_column_name(self.class.primary_key)} = #{quote_value(id)}",
                  "#{self.class.name} Publish"
                )
              end
              after_publish if respond_to?(:after_publish)
            end
            self.published = true
          end
        end    
            
        def status
          live? ? :published : :draft
        end        

        def status_name
          status.to_s.titleize
        end

        def live?
          self.class.versioned? ? live_version.version == draft.version && published? : true
        end
        
      end
    end
  end
end
