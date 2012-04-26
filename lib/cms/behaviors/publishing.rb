module Cms
  module Behaviors

    # Allows content to be marked as publishable or not. In practice, this has a direct dependency on
    # Versioning, so it may not make sense to be separated out this way.
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
          attr_accessible :publish_on_save

          after_save :publish_for_non_versioned
        
          scope :published, :conditions => {:published => true}
          scope :unpublished, lambda {
            if versioned?
              { :joins => :versions,
                :conditions =>
                  "#{connection.quote_table_name(version_table_name)}.#{connection.quote_column_name('version')} > " +
                  "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name('version')}",
                :select => "distinct #{connection.quote_table_name(table_name)}.*" }
            else
              { :conditions => { :published => false } }
            end
          }

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

        # Force the publishing of this block.
        #
        # Warning: The behavior of calling the following on an existing block:
        #   block.save_on_publish = true
        #   block.save!
        #
        # Is different than calling:
        #   block.publish!
        #
        # And it probably shouldn't be. Try to merge the 'else' with the 'Versioning#create_or_update' method to eliminate duplication.
        #
        # In addition, after_publish is NOT called if you do:
        #   block.save_on_publish = true
        #   block.save!
        # which will cause problems if blocks are updated via the method (like with the UI)
        def publish!
          if new_record?
            self.publish_on_save = true
            save!
          else
            # Do this for publishing existing blocks.
            transaction do
              if self.class.versioned?
                d = draft

                # We only need to publish if this isn't already published
                # or the draft version is greater than the live version
                if !self.published? || d.version > self.version
                  
                  d.update_attributes(:published => true)

                  # copy values from the draft to the main record
                  quoted_attributes = d.send(:arel_attributes_values, false, false, self.class.versioned_columns)

                  #the values from the draft MAY have a relation of the versioned module
                  #as opposed to the actual class itself
                  #eg Page::Version, and not Page
                  #so remap to the actual arel_table´
                  #I haven't figured out why this is, but I know it happens when you call save! on Page
                  #during seeding of data
                  if self.class.arel_table.name != quoted_attributes.keys[0].relation.name
                    quoted_attributes = quoted_attributes.inject({}){|hash, pair| hash[self.class.arel_table[pair[0].name]] = pair[1]; hash}
                  end

                  # Doing the SQL ourselves to avoid callbacks
                  self.class.unscoped.where(self.class.arel_table[self.class.primary_key].eq(id)).arel.update(quoted_attributes)
                end
              else
                connection.update(
                  "UPDATE #{self.class.quoted_table_name} " +
                  "SET published = #{connection.quote(true, self.class.columns_hash["published"])} " +
                  "WHERE #{connection.quote_column_name(self.class.primary_key)} = #{quote_value(id)}",
                  "#{self.class.name.demodulize} Publish"
                )
              end
              after_publish if respond_to?(:after_publish)
            end
            self.published = true
          end
        end    
            
        def status
          return @status if @status
          @status = live? ? :published : :draft
        end

        def status_name
          status.to_s.titleize
        end

        def live?
          if self.class.versioned?
            if (respond_to?(:latest_version) && self.latest_version)
              version == latest_version && published?
            else
              live_version.version == draft.version && published?
            end
          else
            true
          end
        end
        
      end
    end
  end
end
