module Cms
  class Attachment < ActiveRecord::Base

    cattr_accessor :definitions, :instance_writer => false
    @@definitions = {}.with_indifferent_access

    cattr_reader :configuration

    attr_accessor :attachable_class

    before_save :set_section
    before_save :set_data_file_path
    before_create :setup_attachment
    before_create :set_cardinality

    belongs_to :attachable, :polymorphic => true

    is_archivable; is_publishable; uses_soft_delete; is_userstamped; is_versioned

    #TODO change this to a simple method
    #def named(mid)
    # find_all_by_name mid
    # end
    # ...or even get rid of it
    scope :named, lambda {|name|
      {:conditions => {:attachment_name => name.to_s}}
    }

    scope :multiple, :conditions => {:cardinality => "multiple"}

    validates_presence_of :data_file_path, :if => Proc.new {|a| a.attachable_type == "AbstractFileBlock"}
    validates_uniqueness_of :data_file_path, :if => Proc.new {|a| a.attachable_type == "AbstractFileBlock"}

    class << self
      def definitions_for(klass, type)
        definitions[klass].inject({}) {|d, (k, v)| d[k.capitalize] = v if v["type"] == type; d}
      end

    include Cms::Addressable
    include Cms::Addressable::DeprecatedPageAccessors
    has_one :section_node, :as => :node, :class_name => 'Cms::SectionNode'
    alias :node :section_node
      def configuration
        @@configuration ||= Cms::Attachments.configuration
      end

      def lambda_for(key)
        lambda do |clip|
          clip.instance.new_record? ? "" : clip.instance.config_value_for(key)
        end
      end


      def find_live_by_file_path(path)
        Attachment.published.not_archived.find_by_data_file_path path
      end

      def configure_paperclip
        has_attached_file :data,
          #TODO: url's should probably not be configurable
          :url =>  lambda_for(:url),
          :path => lambda_for(:path),
          :styles => lambda_for(:styles),

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
      definitions[content_block_class][asset_name][key] || configuration.send(key)
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

    def attachment_link
      if attachable.published? && attachable.live_version?
        data_file_path
      else
        "/cms/attachments/#{id}?version=#{attachable.version}"
      end
    end

    def public?
      section ? section.public? : false
    end

    def is_image?
      %w[jpg gif png jpeg].include?(data_file_extension)
    end

    def url(style_name = configuration.default_style)
      data.url(style_name)
    end

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


    private

    def data_file_extension
      data_file_name.split('.').last.downcase if data_file_name['.']
    end

    def set_section
      self.section = Section.root.first if section_id.blank?

      if section_node && !section_node.new_record? && section_node.section_id != section_id
        section_node.move_to_end(Section.find(section_id))
      else
        build_section_node(:node => self, :section_id => section_id)
      end
    end

    def set_data_file_path
      if data_file_path.blank?
        self.data_file_path = "/attachments/#{content_block_class}_#{data_file_name}"
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
      self.cardinality = definitions[content_block_class][asset_name][:type].to_s
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
