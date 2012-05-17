module Cms
  class Attachment < ActiveRecord::Base

    MULTIPLE = 'multiple'

    SANITIZATION_REGEXES = [[/\s/, '_'], [/[&+()]/, '-'], [/[=?!'"{}\[\]#<>%]/, '']]
    #' this tic cleans up emacs ruby mode

    self.table_name = :cms_attachments

    cattr_accessor :definitions, :instance_writer => false
    @@definitions = {}.with_indifferent_access
    cattr_reader :configuration
    attr_accessor :attachable_class
    attr_accessible :attachable_class

    before_validation :set_cardinality
    before_save :set_section, :sanitized_file_path_and_name
    before_create :setup_attachment

    belongs_to :attachable, :polymorphic => true

    include DefaultAccessible
    attr_accessible :data, :attachable, :attachment_name

    validates :attachment_name, :attachable_type, :presence => true

    include Cms::Addressable
    include Cms::Addressable::DeprecatedPageAccessors
    has_one :section_node, :as => :node, :class_name => 'Cms::SectionNode'
    alias :node :section_node

    is_archivable; is_publishable; uses_soft_delete; is_userstamped; is_versioned

    #TODO change this to a simple method
    #def named(mid)
    # find_all_by_name mid
    # end
    # ...or even get rid of it
    scope :named, lambda { |name|
      {:conditions => {:attachment_name => name.to_s}}
    }

    scope :multiple, :conditions => {:cardinality => MULTIPLE}

    FILE_BLOCKS = "Cms::AbstractFileBlock"
    validates_presence_of :data_file_path, :if => Proc.new { |a| a.attachable_type == FILE_BLOCKS }
    validates_uniqueness_of :data_file_path, :message =>"must be unique. (Another file, image or page is already using '%{value}').", :if => Proc.new { |a| a.attachable_type == FILE_BLOCKS }

    class << self

      # Makes file paths more URL friendly
      def sanitize_file_path(file_path)
        SANITIZATION_REGEXES.inject(file_path.to_s) do |s, (regex, replace)|
          s.gsub(regex, replace)
        end
      end

      def definitions_for(klass, type)
        definitions[klass].inject({}) { |d, (k, v)| d[k.capitalize] = v if v["type"] == type; d }
      end

      def configuration
        @@configuration ||= Cms::Attachments.configuration
      end

      # Returns a Proc that can be used to dynamically determine styles based on the Cms::Attachment class
      #
      # Paperclip can handle a :styles parameter which responds to :call(Paperclip::Attachment)
      def dynamically_return_styles
        lambda do |paperclip_attachment|
          cms_attachment = paperclip_attachment.instance

          # Look up the style for the given block
          if cms_attachment.has_assigned_content_type?
            configuration_value(cms_attachment.content_block_class, cms_attachment.attachment_name, :styles)
          else # New attachments that aren't associated with an Attaching type yet have no styles
            {}
          end
        end
      end

      def find_live_by_file_path(path)
        Attachment.published.not_archived.find_by_data_file_path path
      end


      def configure_paperclip
        # @todo This might be better done using subclasses of Attachment for each document instance.
        # We could use single table inheritance to avoid needing to do meta configurations.
        has_attached_file :data,
                          :url => configuration.url,
                          :path => configuration.path,
                          :styles => dynamically_return_styles,

                          # Needed for versioning so that we keep all previous files.
                          :preserve_files => true,

                          #TODO: enable custom processors
                          :processors => configuration.processors,
                          :default_url => configuration.default_url,
                          :default_style => configuration.default_style,
                          :use_timestamp => configuration.use_timestamp,
                          :whiny => configuration.whiny,
                          :storage => rail_config(:storage),
                          :s3_credentials => rail_config(:s3_credentials),
                          :bucket => rail_config(:s3_bucket)

      end

      # Looks up a value from Rails config
      def rail_config(key)
        Rails.configuration.cms.attachments[key]
      end

      # Looks up the configuration value given:
      # @param [Class] block_class The class of a block which has an attachment.
      # @param [String] name_of_attachment The name of the attachment association (i.e. if was 'has_attachment :photos' then pass 'photo')
      # @param [Symbol] key The key for the value to be fetched (i.e. :styles)
      #
      def configuration_value(block_class, name_of_attachment, key)
        class_definitions = definitions[block_class]
        if class_definitions == nil
          raise "Couldn't find any definitions for '#{block_class}'."
        end
        attachment_definition = class_definitions[name_of_attachment]
        if attachment_definition == nil
          raise "Verify that '#{block_class}' defines an attachment named ':#{name_of_attachment}'."
        end
        attachment_definition[key] || configuration.send(key)
      end

    end


    def section=(section)
      dirty! if self.section != section
      super(section)
    end

    def config_value_for(key)
      self.class.configuration_value(content_block_class, attachment_name, key)
    end

    def content_block_class
      attachable_class || attachable.try(:class).try(:name) || attachable_type
    end

    def icon
      {
          :doc => %w[doc],
          :gif => %w[gif jpg jpeg png tiff bmp],
          :htm => %w[htm html],
          :pdf => %w[pdf],
          :ppt => %w[ppt],
          :swf => %w[swf],
          :txt => %w[txt],
          :xls => %w[xls],
          :xml => %w[xml],
          :zip => %w[zip rar tar gz tgz]
      }.each do |icon, extensions|
        return icon if extensions.include?(data_file_extension)
      end
      :file
    end

    # For authorized users, return the path to get the specific version of the file associated with this attachment.
    # Guests should always get 'data_file_path' which is the public version of the asset.
    def attachment_version_path
      "/cms/attachments/#{id}?version=#{version}"
    end

    def public?
      section ? section.public? : false
    end

    def is_image?
      %w[jpg gif png jpeg].include?(data_file_extension)
    end

    # Returns a Paperclip generated relative path to the file (with thumbnail sizing)
    def url(style_name = configuration.default_style)
      data.url(style_name)
    end

    # Returns the absolute file location of the underlying asset
    def path(style_name = configuration.default_style)
      data.path(style_name)
    end

    def original_filename
      data_file_name
    end

    alias :file_name :original_filename

    def size
      data_file_size
    end

    def content_type
      data_content_type
    end

    alias :file_type :content_type

    # Returns the definitions for this particular attachment type.
    # @return [Hash] Empty Hash if no definition have been defined for this attachment.
    def config
      content_defs = definitions[content_block_class] ? definitions[content_block_class] : {}
      content_defs[attachment_name] ? content_defs[attachment_name] : {}
    end

    # Determines if this Attachment has access to configuration information yet. Until it is assigned to an Attaching object,
    # it will lack style information.
    def has_assigned_content_type?()
      attachable_type && attachment_name
    end

    protected

    private

    def data_file_extension
      data_file_name.split('.').last.downcase if data_file_name && data_file_name['.']
    end

    # Filter - Ensure that paths are going to URL friendly (and won't need encoding for special characters.')
    def sanitized_file_path_and_name
      if data_file_path
        self.data_file_path = self.class.sanitize_file_path(data_file_path)
        if !data_file_path.empty? && !data_file_path.starts_with?("/")
          self.data_file_path = "/#{data_file_path}"
        end
      end

      if data_file_name
        self.data_file_name = self.class.sanitize_file_path(data_file_name)
      end
    end

    def set_section
      unless parent
        self.parent = Section.root.first
      end
    end

    def setup_attachment
      data.instance_variable_set :@url, config_value_for(:url)
      data.instance_variable_set :@path, config_value_for(:path)
      data.instance_variable_set :@styles, config_value_for(:styles)
      data.instance_variable_set :@normalized_styles, nil
      data.send :post_process_styles
    end

    # Attachments should always be configured with a cardinality
    def set_cardinality
      unless cardinality
        self.cardinality = config[:type].to_s
      end

    end

    # Forces this record to be changed, even if nothing has changed
    # This is necessary if just the section.id has changed, for example
    # test if this is necessary now that the attributes are in the
    # model itself.
    def dirty!
      # Seems like a hack, is there a better way?
      self.updated_at = Time.now
    end
  end
end
