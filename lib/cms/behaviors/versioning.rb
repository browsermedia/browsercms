module Cms
  module Behaviors

    # This behavior adds Versioning to an ActiveRecord object. It seriously monkeys with how objects are saved or updated.
    #
    # This implementation is pretty tied to Rails 3 ActiveRecord. Here's how I understand it works:
    # ActiveRecord alias chain- Here is the order that methods get called.
    #
    # save
    #   save_with_transactions
    #   save_with_dirty
    #   save_with_validations
    #   AR::Base#save (save_without_validations)
    #   AR::Base#create_or_update_with_callbacks
    #
    #
    #  AR::Base - Defines a 'save' method with no params
    #  AR::Validations - alias save to a save_with_validations (which takes params)
    #  ActiveRecord Object has:
    #  - save_with_validations(options)
    #  - save_without_validation() - (Original save)
    #
    module Versioning
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end

      module MacroMethods
        def versioned?
          !!@is_versioned
        end

        def is_versioned(options={})
          @is_versioned = true

          @version_foreign_key = (options[:version_foreign_key] || "#{name.underscore}_id").to_s
          @version_table_name = (options[:version_table_name] || "#{table_name.singularize}_versions").to_s

          extend ClassMethods
          include InstanceMethods

          has_many :versions, :class_name => version_class_name, :foreign_key => version_foreign_key
          after_save :update_latest_version

          before_validation :initialize_version
          before_save :build_new_version
          attr_accessor :skip_callbacks

          attr_accessor :revert_to_version

          #Define the version class
          const_set("Version", Class.new(ActiveRecord::Base)).class_eval do
            class << self;
              attr_accessor :versioned_class
            end

            def versioned_class
              self.class.versioned_class
            end

            def versioned_object_id
              send("#{versioned_class.name.underscore}_id")
            end

            def versioned_object
              send(versioned_class.name.underscore.to_sym)
            end
          end unless self.const_defined?("Version")

          version_class.versioned_class = self

          version_class.belongs_to(name.underscore.to_sym, :foreign_key => version_foreign_key)

          version_class.is_userstamped if userstamped?

        end
      end
      module ClassMethods
        def version_class
          const_get "Version"
        end

        def version_class_name
          "#{name}::Version"
        end

        def version_foreign_key
          @version_foreign_key
        end

        def version_table_name
          @version_table_name
        end

        def versioned_columns
          @versioned_columns ||= (version_class.new.attributes.keys -
              (%w[id lock_version position version_comment created_at updated_at created_by_id updated_by_id type] + [version_foreign_key]))
        end
      end
      module InstanceMethods
        def initialize_version
          self.version = 1 if new_record?
        end

        # Used in migrations and as a callback.
        def update_latest_version
          #Rails 3 could use update_column here instead
          if respond_to? :latest_version
            sql = "UPDATE #{self.class.table_name} SET latest_version = #{draft.version} where id = #{self.id}"
            connection.execute sql
            self.latest_version = draft.version # So we don't need to #reload this object. Probably marks it as dirty though, which could have weird side effects.
          end
        end

        def build_new_version_and_add_to_versions_list_for_saving
          # First get the values from the draft
          attrs = draft_attributes

          # Now overwrite all values
          (self.class.versioned_columns - %w(  version  )).each do |col|
            attrs[col] = send(col)
          end

          attrs[:version_comment] = @version_comment || default_version_comment
          @version_comment = nil
          new_version = versions.build(attrs)
          new_version.version = new_record? ? 1 : (draft.version.to_i + 1)
          after_build_new_version(new_version) if respond_to?(:after_build_new_version)
          new_version
        end

        def draft_attributes
          # When there is no draft, we'll just copy the attributes from this object
          # Otherwise we need to use the draft
          d = new_record? ? self : draft
          self.class.versioned_columns.inject({}) { |attrs, col| attrs[col] = d.send(col); attrs }
        end

        def default_version_comment
          if new_record?
            "Created"
          else
            "Changed #{(changes.keys - %w[  version created_by_id updated_by_id  ]).sort.join(', ')}"
          end
        end

        def publish_if_needed
          logger.debug { "#{self.class}#publish_if_needed. publish? = '#{!!@publish_on_save}'"}

          if @publish_on_save
            publish
            @publish_on_save = nil
          end
        end


        #  
        #ActiveRecord 3.0.0 call chain
        # ActiveRecord 3 now uses basic inheritence rather than alias_method_chain.  The order in which ActiveRecord::Base
        # includes methods (at the bottom of activerecord) repeatedly overrides save/save! with chains of 'super'
        #
        # Callstack order as observed
        # 1. ActiveRecord::Base#save - The original method called by client
        #
        #  AR::Transactions#save
        #  AR::Dirty#save
        #  AR::Validations#save
        #  ActiveRecord::Persistence#save
        #  ActiveRecord::Persistence#create_or_update
        #  AR::Callbacks#create_or_update (runs :save callbacks)
        #
        #
        #
        # This aliases the original ActiveRecord::Base.save method, in order to change
        # how calling save works. It should do the following things:
        #
        # 1. If the record is unchanged, no save is performed, but true is returned. (Skipping after_save callbacks)
        # 2. If its an update, a new version is created and that is saved.
        # 3. If new record, its version is set to 1, and its published if needed.
        def create_or_update
          logger.debug {"#{self.class}#create_or_update called. Published = #{!!publish_on_save}"}
          self.skip_callbacks = false
          unless different_from_last_draft?
            logger.debug {"No difference between this version and last. Skipping save"}
            self.skip_callbacks = true
            return true
          end
          logger.debug {"Saving #{self.class} #{self.attributes}"}
          if new_record?
            self.version = 1
            # This should call ActiveRecord::Callbacks#create_or_update, which will correctly trigger the :save callback_chain
            saved_correctly = super
            changed_attributes.clear
          else
            logger.debug {"#{self.class}#update"}
            # Because we are 'skipping' the normal ActiveRecord update here, we must manually call the save callback chain.
            run_callbacks :save do
              saved_correctly = @new_version.save
            end
          end
          publish_if_needed
          return saved_correctly
        end

        # Build a new version of this record and associate it with this record.
        #
        # Called as a before_create in order to correctly allow any other associations to be saved correctly.
        # Called explicitly during update, where it will just define the new_version to be saved.
        def build_new_version
          @new_version = build_new_version_and_add_to_versions_list_for_saving
          logger.debug {"New version of #{self.class}::Version is #{@new_version.attributes}"}
        end

        # Implementation from BrowserCMS 3.1 (Rails 2 API). Left for reference while tests are being fixed for Rails 3 upgrade.
        #
        #
        # This overrides the 'save' method from activerecord
        # Things happening here:
        # 1. If the record is unchanged, no save is performed, but true is returned (Make a separete call back)
        # 2. If its an update, a new version is created and that is saved.
        # 3. If new record, its version is set to 1, and its published if needed.
        #
        # Note: According to AR::Callbacks, save is its own transactions, so should be no need for separate TX.
#        def save(perform_validations=true)
#          transaction do
#            #logger.info "..... Calling valid?"
#            return false unless !perform_validations || valid?
#
#            if different_from_last_draft?
#              #logger.info "..... Changes => #{changes.inspect}"
#            else
#              #logger.info "..... No Changes"
#              return true
#            end
#
#            #logger.info "..... Calling before_save"
#            return false if callback(:before_save) == false
#
#            if new_record?
#              #logger.info "..... Calling before_create"
#              return false if callback(:before_create) == false
#            else
#              #logger.info "..... Calling before_update"
#              return false if callback(:before_update) == false
#            end
#
#            #logger.info "..... Calling build_new_version"
#            new_version = build_new_version
#            #logger.info "..... Is new version valid? #{new_version.valid?}"
#            if new_record?
#              self.version = 1
#              #logger.info "..... Calling create_without_callbacks"
#              if result = create_without_callbacks
#                #logger.info "..... Calling after_create"
#                if callback(:after_create) != false
#                  #logger.info "..... Calling after_save"
#                  callback(:after_save)
#                end
#
#                if @publish_on_save
#                  publish
#                  @publish_on_save = nil
#                end
#                changed_attributes.clear
#              end
#              result
#            elsif new_version
#              #logger.info "..... Calling save"
#              if result = new_version.save
#                #logger.info "..... Calling after_save"
#                if callback(:after_update) != false
#                  #logger.info "..... Calling after_update"
#                  callback(:after_save)
#                end
#
#                if @publish_on_save
#                  publish
#                  @publish_on_save = nil
#                end
#                changed_attributes.clear
#              end
#              result
#            end
#            true
#          end
#        end

        def save!(perform_validations=true)
          save(:validate=>perform_validations) || raise(ActiveRecord::RecordNotSaved.new(errors.full_messages))
        end

        def draft
          versions.first(:order => "version desc")
        end

        def draft_version?
          version == draft.version
        end

        def live_version
          find_version(self.class.find(id).version)
        end

        def live_version?
          version == self.class.find(id).version
        end

        def current_version
          find_version(self.version)
        end

        def find_version(number)
          versions.first(:conditions => {:version => number})
        end

        def as_of_draft_version
          build_object_from_version(draft)
        end

        # Find a Content Block as of a specific version.
        #
        # @param [Integer] version The specific version of the block to look up
        # @return [ContentBlock] The block as of the state it existed at 'version'.
        def as_of_version(version)
          v = find_version(version)
          raise ActiveRecord::RecordNotFound.new("version #{version.inspect} does not exist for <#{self.class}:#{id}>") unless v
          build_object_from_version(v)
        end

        def revert
          draft_version = draft.version
          revert_to(draft_version - 1) unless draft_version == 1
        end

        def revert_to_without_save(version)
          raise "Version parameter missing" if version.blank?
          self.revert_to_version = find_version(version)
          raise "Could not find version #{version}" unless revert_to_version
          (self.class.versioned_columns - ["version"]).each do |a|
            send("#{a}=", revert_to_version.send(a))
          end
          self.version_comment = "Reverted to version #{version}"
          self
        end

        def revert_to(version)
          revert_to_without_save(version)
          save
        end

        def version_comment
          @version_comment
        end

        def version_comment=(version_comment)
          @version_comment = version_comment
          send(:changed_attributes)["version_comment"] = @version_comment
        end

        def different_from_last_draft?
          return true if self.changed?
          last_draft = self.draft
          return true unless last_draft
          (self.class.versioned_columns - %w(  version  )).each do |col|
            return true if self.send(col) != last_draft.send(col)
          end
          return false
        end

        private

        # Given a ::Version object of a given type, create an original object from its attributes.
        #
        # @param [Class#name::Version] version_of_object (i.e. HtmlBlock::Version)
        # @return [Class#name] i.e. HtmlBlock
        def build_object_from_version(version_of_object)
          obj = self.class.new

          (self.class.versioned_columns + [:version, :created_at, :created_by_id, :updated_at, :updated_by_id]).each do |a|
            obj.send("#{a}=", version_of_object.send(a))
          end
          obj.id = id
          obj.lock_version = lock_version

          # Need to do this so associations can be loaded
          obj.instance_variable_set("@persisted", true)
          obj.instance_variable_set("@new_record", false)

          # Callback to allow us to load other data when an older version is loaded
          obj.after_as_of_version if obj.respond_to?(:after_as_of_version)

          # Last but not least, clear the changed attributes
          if changed_attrs = obj.send(:changed_attributes)
            changed_attrs.clear
          end

          obj
        end
      end
    end

  end
end
