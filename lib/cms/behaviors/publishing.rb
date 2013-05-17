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
        
          attr_accessible :publish_on_save, :as
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

        # Can specify whether to save this block as a draft using a terser syntax.
        # These two calls behave identically
        #   - Cms::HtmlBlock.create(name: "Shorter", as: :draft)
        #   - Cms::HtmlBlock.create(name: "Longer",  publish_on_save: false)
        # @param [Symbol] status :draft to not publish on the next save. All other values are ignored.
        def as=(status)
          if status == :draft
            self.publish_on_save = false
          end
        end
        # Whether or not this object will be published the next time '.save' is called.
        # @return [Boolean] True unless explicitly set otherwise.
        def publish_on_save
          if @publish_on_save.nil?
            @publish_on_save = true
          end
          @publish_on_save
        end

        # Set whether or not this object will be published next time '.save' is called.
        # This status resets to true after calling '.save'
        def publish_on_save=(publish)
          @publish_on_save = publish
        end

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

        def publish_if_needed
          if publish_on_save
            publish
          else
            self.publish_on_save = true
          end
        end

        # Publishes the latest previously saved version of content as published. This will not create a new version,
        # and will not persist changes made to a record.
        #
        # @return [Boolean] true if there was a draft record that was published, false otherwise.
        def publish
          publish!
        rescue Exception => e
          logger.warn("Could not publish, #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
          false
        end

        # Saves a draft copy of this content item. This will create a new record in the _versions table for this item, but
        # will not update the existing published record.
        def save_draft
          self.publish_on_save = false
          save
        end

        # Publishes the latest draft version of a block. See .publish for more documentation. Can throw errors if publishing failed for unexpected reasons.
        # Note: Having separate .publish! and .publish methods is probably no longer necessary. In practice, only .publish is probably needed.
        # @return [Boolean] true if the block had a draft that was published, false otherwise.
        def publish!
          did_publish = false
          if new_record?
            ActiveSupport::Deprecation.warn "Calling .publish! on a new record no longer saves the record. Call '.save' to persist and publish the record.", caller
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
                  did_publish = true
                end
              else
                connection.update(
                  "UPDATE #{self.class.quoted_table_name} " +
                  "SET published = #{connection.quote(true, self.class.columns_hash["published"])} " +
                  "WHERE #{connection.quote_column_name(self.class.primary_key)} = #{quote_value(id)}",
                  "#{self.class.name.demodulize} Publish"
                )
                did_publish = true
              end
              after_publish if respond_to?(:after_publish)
            end
            self.published = true
          end
          did_publish
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
            unless persisted?
              return false
            end
            if respond_to?(:latest_version) && self.latest_version
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
