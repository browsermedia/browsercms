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

    before_save :set_section
    before_save :set_default_path
    before_validation :ensure_sanitized_file_path, :set_data_defaults
    before_create :setup_attachment
    before_create :set_cardinality
    belongs_to :attachable, :polymorphic => true

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
    validates_uniqueness_of :data_file_path, :if => Proc.new { |a| a.attachable_type == FILE_BLOCKS }

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

      def lambda_for(key)
        lambda do |clip|
          if clip.instance.new_record?
            key == :styles ? {} : ""
          else
            clip.instance.config_value_for(key)
          end
        end
      end


      def find_live_by_file_path(path)
        Attachment.published.not_archived.find_by_data_file_path path
      end

      def configure_paperclip
        has_attached_file :data,
                          #TODO: url's should probably not be configurable
                          :url => lambda_for(:url),
                          :path => lambda_for(:path),
                          :styles => lambda_for(:styles),

                          # Needed for versioning so that we keep all previous files.
                          :preserve_files => true,

                          #TODO: enable custom processors
                          :processors => configuration.processors,
                          :defult_url => configuration.default_url,
                          :default_style => configuration.default_style,
                          :storage => configuration.storage,
                          :use_timestamp => configuration.use_timestamp,
                          :whiny => configuration.whiny,

                          :s3_credentials => configuration.s3_credentials,
                          :bucket => configuration.bucket
      end
    end

    def section=(section)
      dirty! if self.section != section
      super(section)
    end

    def config_value_for(key)
      class_definitions = definitions[content_block_class]
      if class_definitions == nil
        raise "Couldn't find any definitions for #{content_block_class}."
      end
      attachment_definition = class_definitions[attachment_name]
      if attachment_definition == nil
        raise "Verify that '#{content_block_class}' defines an attachment named ':#{attachment_name}'."
      end
      attachment_definition[key] || configuration.send(key)
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
    # @todo I really want this to return data_file_path instead.
    def path(style_name = configuration.default_style)
      data.path(style_name)
    end

    alias :full_file_location :path

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

    protected

    private

    def set_data_defaults
      unless attachable_version
        self.attachable_version = 1
      end
    end

    def data_file_extension
      data_file_name.split('.').last.downcase if data_file_name && data_file_name['.']
    end

    # Filter - Sets a default path if none was specified.
    # Some types of attachments may require a path though (see validations above)
    def set_default_path
      if data_file_path.blank?
        self.data_file_path = "/attachments/#{content_block_class}_#{data_file_name}"
      end
    end

    # Filter - Ensure that paths are going to URL friendly (and won't need encoding for special characters.')
    def ensure_sanitized_file_path
      if data_file_path
        self.data_file_path = self.class.sanitize_file_path(data_file_path)
        if !data_file_path.empty? && !data_file_path.starts_with?("/")
          self.data_file_path = "/#{data_file_path}"
        end
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

    def set_cardinality
      self.cardinality = definitions[content_block_class][attachment_name][:type].to_s
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
