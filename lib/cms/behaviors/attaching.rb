module Cms
  # @todo Comments need to be cleaned up to get rid of 'uses_paperclip'
  module Behaviors
    # Allows one or more files to be attached to content blocks.
    #
    # class Book
    #   acts_as_content_block
    #   uses_paperclip
    # end
    #
    # It would probably be nice to do something like:
    #
    # class Book
    #   acts_as_content_block :uses_paperclip => true
    # end
    #
    # has_attached_asset and has_many_attached_assets are very similar.
    # They both define a couple of methods in the content block:
    #
    # class Book
    #   uses_paperclip
    #
    #   has_attached_asset :cover
    #   has_many_attached_assets :drafts
    # end
    #
    #  book = Book.new
    #  book.cover = nil #is basically calling: book.assets.named(:cover).first
    #  book.drafts = [] #is calling book.assets.named(:drafts)
    #
    #  Book#cover and Book#drafts both return Asset objects as opposed to what
    #  happens with stand alone Paperclip:
    #
    #  class Book
    #     has_attached_file :invoice #straight Paperclip
    #  end
    #
    #  Book.new.invoice # returns an instance of Paperclip::Attachment
    #
    #  However, Asset instances respond to most of the same methods
    #  Paperclip::Attachments do (at least the most usefull ones and the ones
    #  that make sense for this implementation). Please see asset.rb for more on
    #  this.
    #
    #  At the moment, calling has_attached_asset does not enforce that only
    #  one asset is created, it only defines a method that returns the first one
    #  ActiveRecord finds. It would be possible to do if that makes sense.
    #
    #  In terms of validations, I'm aiming to expose the same 3 class methods
    #  Paperclip exposes, apart from those needed by BCMS itself (like enforcing
    #  unique attachment paths) but this is not ready yet:
    #
    #  validates_asset_size
    #  validates_asset_presence
    #  validates_asset_content_type
    #
    module Attaching

      def self.included(base)
        base.extend MacroMethods
      end

      module MacroMethods

        # Adds additional behavior to a model which allows it to have attachments.
        # Typically, clients will not need to call this directly. Enabling attachments is normally done via:
        #
        #   acts_as_content_block :allow_attachments => false
        #
        ## By default, blocks can have attachments.
        def allow_attachments
          extend ClassMethods
          extend Validations
          include InstanceMethods

          # Allows a block to be associated with a list of uploaded attachments (done via AJAX)
          attr_accessor :attachment_id_list, :attachments_changed

          Cms::Attachment.definitions[self.name] = {}
          has_many :attachments, :as => :attachable, :dependent => :destroy, :class_name => 'Cms::Attachment', :autosave => false

          accepts_nested_attributes_for :attachments,
                                        :allow_destroy => true,
                                        # New attachments must have an uploaded file
                                        :reject_if => lambda { |a| a[:data].blank? && a[:id].blank? }
          attr_accessible :attachments_attributes, :attachment_id_list, :attachments_changed

          validates_associated :attachments
          before_validation :initialize_attachments, :check_for_updated_attachments
          after_validation :filter_generic_attachment_errors

          before_create :associate_new_attachments
          before_save :ensure_status_matches_attachable

          after_save :save_associated_attachments

        end
      end

      #NOTE: Assets should be validated when created individually.
      module Validations
        def validates_attachment_size(name, options = {})

          min = options[:greater_than] || (options[:in] && options[:in].first) || 0
          max = options[:less_than] || (options[:in] && options[:in].last) || (1.0/0)
          range = (min..max)
          message = options[:message] || "#{name.to_s.capitalize} file size must be between :min and :max bytes."
          message = message.gsub(/:min/, min.to_s).gsub(/:max/, max.to_s)

          #options[:unless] = Proc.new {|r| r.a.asset_name != name.to_s}

          validate(options) do |record|
            record.attachments.each do |attachment|
              next unless attachment.attachment_name == name.to_s
              record.errors.add_to_base(message) unless range.include?(attachment.data_file_size)
            end
          end
        end

        def validates_attachment_presence(name, options = {})
          message = options[:message] || "Must provide at least one #{name}"
          validate(options) do |record|
            record.errors.add(:attachment, message) unless record.attachments.any? { |a| a.attachment_name == name.to_s }
          end
        end

        def validates_attachment_content_type(name, options = {})
          validation_options = options.dup
          allowed_types = [validation_options[:content_type]].flatten
          validate(validation_options) do |record|
            attachments.each do |a|
              if !allowed_types.any? { |t| t === a.data_content_type } && !(a.data_content_type.nil? || a.data_content_type.blank?)
                record.add_to_base(options[:message] || "is not one of #{allowed_types.join(', ')}")
              end
            end

          end
        end

        # Define at :set_attachment_path if you would like to override the way file_path is set
        def handle_setting_attachment_path
          if self.respond_to? :set_attachment_path
            set_attachment_path
          else
            use_default_attachment_path
          end
        end
      end

      module ClassMethods


        # Defines an single attachement with a given name.
        #
        # @param [Symbol] name The name of the attachment
        # @param [Hash] options Accepts most Paperclip options for Paperclip::ClassMethods.has_attached_file
        # @see http://rubydoc.info/gems/paperclip/Paperclip/ClassMethods:has_attached_file
        def has_attachment(name, options = {})
          options[:type] = :single
          options[:index] = Cms::Attachment.definitions[self.name].size
          Cms::Attachment.definitions[self.name][name] = options

          define_method name do
            attachment_named(name)
          end
          define_method "#{name}?" do
            (attachment_named(name) != nil)
          end
        end

        # Allows multiple attachments under a specific name.
        #
        # @param [Symbol] name The name of the attachments.
        # @param [Hash] options Accepts most Paperclip options for Paperclip::ClassMethods.has_attached_file
        # @see http://rubydoc.info/gems/paperclip/Paperclip/ClassMethods:has_attached_file
        def has_many_attachments(name, options = {})
          options[:type] = :multiple
          Cms::Attachment.definitions[self.name][name] = options

          define_method name do
            attachments.named name
          end

          define_method "#{name}?" do
            !attachments.named(name).empty?
          end
        end

        # Find all attachments as of the given version for the specified block. Excludes attachments that were
        # deleted as of a version.
        #
        # @param [Integer] version_number
        # @param [Attaching] attachable The object with attachments
        # @return [Array<Cms::Attachment>]
        def attachments_as_of_version(version_number, attachable)
          found_versions = Cms::Attachment::Version.where(:attachable_id => attachable.id).
              where(:attachable_type => attachable.attachable_type).
              where(:attachable_version => version_number).
              order(:version).all
          found_attachments = []

          found_versions.each do |av|
            record = av.build_object_from_version
            found_attachments << record
          end
          found_attachments.delete_if { |value| value.deleted? }
          found_attachments
        end

        # Return all definitions for a given class.
        def definitions_for(name)
          Cms::Attachment.definitions[self.name][name]
        end
      end

      module InstanceMethods

        # This ensures that if a change is made to an attachment, that this model is also marked as changed.
        # Otherwise, if the change isn't detected, this record won't save a new version (since updates are rejected if no changes were made)
        def check_for_updated_attachments
          if attachments_changed == "true" || attachments_were_updated?
            changed_attributes['attachments'] = "Uploaded new files"
          end
        end

        def attachments_were_updated?
          attachments.each do |a|
            if a.changed?
              return true
            end
          end
          false
        end
        # Returns a list of all attachments this content type has defined.
        # @return [Array<String>] Names
        def attachment_names
          Cms::Attachment.definitions[self.class.name].keys
        end

        def after_publish
          attachments.each &:publish
        end

        # Locates the attachment with a given name
        # @param [Symbol] name The name of the attachment
        def attachment_named(name)
          attachments.select { |item| item.attachment_name.to_sym == name }.first
        end

        def unassigned_attachments
          return [] if attachment_id_list.blank?
          Cms::Attachment.find attachment_id_list.split(',').map(&:to_i)
        end

        def all_attachments
          attachments << unassigned_attachments
        end

        def attachable_type
          self.class.name
        end

        # Versioning Callback - This will result in a new version of attachments being created every time the attachable is updated.
        #   Allows a complete version history to be reconstructed.
        # @param [Versionable] new_version
        def after_build_new_version(new_version)
          attachments.each do |a|
            a.attachable_version = new_version.version
          end
        end

        # Version Callback - Reconstruct this object exactly as it was as of a particularly version
        # Called after the object is 'reset' to the specific version in question.
        def after_as_of_version()
          @attachments_as_of = self.class.attachments_as_of_version(version, self)


          # Override #attachments to return the original attachments for the current version.
          metaclass = class << self;
            self;
          end
          metaclass.send :define_method, :attachments do
            @attachments_as_of
          end
        end

        # Callback - Ensure attachments get reverted whenver a block does.
        def after_revert(version)
          version_number = version.version
          attachments.each do |a|
            a.revert_to(version_number, {:attachable_version => self.version+1})
          end
        end

        # Ensures that attachments exist for form, since it uses attachments.each to iterate over them.
        #   Design Qualm: I don't like that this method has to exist, since its basically obscuring the fact that
        #   individual attachments don't exist when an object is created.
        def ensure_attachment_exists
          attachment_names.each do |n|
            unless attachment_named(n.to_sym)
              # Can't use attachments.build because sometimes its an array
              attachments << Attachment.new(:attachment_name => n, :attachable => self)
            end
          end
        end

        # @return [Array<Cms::Attachment>]
        def multiple_attachments
          attachments.select { |a| a.cardinality == Attachment::MULTIPLE }
        end

        private

        # Saves associated attachments if they were updated. (Used in place of :autosave=>true, since the CMS Versioning API seems to break that)
        #
        # ActiveRecord Callback
        def save_associated_attachments
          logger.warn "save_associated_attachments #{attachments}"
          attachments.each do |a|
            a.save if a.changed?
          end
        end


        # Filter - Ensures that the status of all attachments matches the this block
        def ensure_status_matches_attachable
          if self.class.archivable?
            attachments.each do |a|
              a.archived = self.archived
            end
          end

          if self.class.publishable?
            attachments.each do |a|
              a.publish_on_save = self.publish_on_save
            end
          end
        end

        # Handles assigning attachments that were created via use of
        # the cms_asset manager.
        #
        # Since Attachments are created via AJAX, we need to go back and associate those with this Attaching object.
        def associate_new_attachments
          unless attachment_id_list.blank?
            ids = attachment_id_list.split(',').map(&:to_i)
            ids.each do |i|
              begin
                attachment = Cms::Attachment.find(i)
              rescue ActiveRecord::RecordNotFound
              end

              # Previously saved attachments shouldn't have an attachable_version or attachable_id yet.
              if attachment
                attachment.attachable_version = self.version
                attachments << attachment
              end

            end
          end
        end

        # We don't want errors like: Attachments is invalid showing up, since they are duplicates
        def filter_generic_attachment_errors
          filter_errors_named([:attachments])
        end

        def initialize_attachments
          attachments.each { |a| a.attachable_class = self.class.name }
        end


        private
        def filter_errors_named(filter_list)
          filtered_errors = self.errors.reject { |err| filter_list.include?(err.first) }

          # reset the errors collection and repopulate it with the filtered errors.
          self.errors.clear
          filtered_errors.each { |err| self.errors.add(*err) }
        end
      end
    end
  end
end
