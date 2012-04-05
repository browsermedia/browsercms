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
      # extend ActiveSupport::Concern

      def self.included(base)
        base.extend MacroMethods
      end

      module MacroMethods
        def has_attachments
          extend ClassMethods
          extend Validations
          include InstanceMethods

          attr_accessor :attachment_id_list

          Cms::Attachment.definitions[self.name] = {}
          has_many :attachments, :as => :attachable, :dependent => :destroy, :class_name => 'Cms::Attachment', :autosave => false

          accepts_nested_attributes_for :attachments,
                                        :allow_destroy => true,
                                        # New attachments must have an uploaded file
                                        :reject_if => lambda { |a| a[:data].blank? && a[:id].blank? }

          validates_associated :attachments
          before_create :assign_attachments
          before_validation :initialize_attachments
          before_save :ensure_status_matches_attachable
          after_save :save_associated_attachments
        end
      end

      #NOTE: Assets should be validated when created individually.
      module Validations
        def validates_attachment_size(name, options = {})

          #if options.delete(:unless)
          #logger.warn "Option :unless is not supported and will be ignored"
          #end

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

        def has_attachment(name, options = {})
          options[:type] = :single
          options[:index] = Cms::Attachment.definitions[self.name].size
          Cms::Attachment.definitions[self.name][name] = options

          define_method name do
            attachments.named(name).last
          end
          define_method "#{name}?" do
            !attachments.named(name).empty?
          end
        end

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
      end

      module InstanceMethods
        def after_publish
          attachments.each &:publish
        end


        def unassigned_attachments
          return [] if attachment_id_list.blank?
          Cms::Attachment.find attachment_id_list.split(',').map(&:to_i)
        end

        def all_attachments
          attachments << unassigned_attachments
        end

        private

        # Callback - :autosave=>true does not work (due to versioning bug)
        def save_associated_attachments
          attachments.each do |a|
            a.save
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

        def assign_attachments
          unless attachment_id_list.blank?
            ids = attachment_id_list.split(',').map(&:to_i)
            ids.each do |i|
              begin
                attachment = Cms::Attachment.find(i)
              rescue ActiveRecord::RecordNotFound
              end
              attachments << attachment if attachment
            end
          end
        end

        def initialize_attachments
          attachments.each { |a| a.attachable_class = self.class.name }
        end

      end
    end
  end
end
