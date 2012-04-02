require 'paperclip'

module Cms
  #Cms::Assets exposes an interface to setup paperclip
  #for BrowserCMS.
  #
  #Cms::Assets::Configuration privides defaults that are suitable
  #for the CMS and that probably make sense for most installations.
  #
  #This module also declares Paperclip interpolations that are used
  #to construct the default url and path.
  #
  # For example, the default path:
  #
  # ":attachments_root/:date_partition/:style/:fingerprint"
  #
  # expands to something like:
  #
  #  Rails.root/tmp/uploads/2011/1/30/thumb/thcu098rc87dgd
  #
  # but can be changed by using paperclip interpolations, either
  # the ones already defined by Paperlip itself, the Cms::Assets
  # module, or user defined.
  #
  # Currently, urls are configurable but they probably shouldn't be.
  #
  # The default url is "/attachments/:filename?style=:style", which
  # is the url the CMS expects to find attachments. (The style parameter
  # was added to support displaying images of different sizes)
  # See controllers/attachments.rb and controllers/content.rb for more on
  # this.
  #
  # As an expmle, Image and FileBlocks override this default url to
  # accomodate user defined ones (currently, the CMS calls them file_paths
  # or attachment_file_path but paperclip calls them url's):
  #
  # class FileBlock < AbstractFileBlock
  #   #...
  #   has_attached_asset :file, :url => ":attachment_file_path"
  # end
  #
  # ":attachment_file_path" will be expanded to whatever value
  # is on the block's data_file_path attribute (formerly attachment_file_path)
  #
  # This interpolation does not take styles into consideration yet.
  module Attachments
    mattr_accessor :configuration

    def self.configure
      configuration = self.configuration
      yield configuration if block_given?
      @@configuration = configuration
      Attachment.configure_paperclip
    end

    def self.configuration
      @@configuration || Configuration.new
    end

     class Configuration
        attr_accessor :url, :path, :styles, :processors, :default_url,
                      :default_style, :storage, :whiny
        attr_accessor :s3_credentials, :bucket
        attr_accessor :attachments_root, :file_permissions

        attr_reader :use_timestamp

        def initialize
          self.url = "/attachments/:full_filename?style=:style"
          self.path = ":attachments_root/:id_partition/:style/:fingerprint"
          self.styles = {}
          self.processors = [:thumbnail]
          #TODO: set a default url that makes sense for BCMS
          self.default_url = "/:attachment/:style/missing.png"
          self.default_style = :original
          self.storage = :filesystem
          self.whiny = false

          self.attachments_root = File.join(Rails.root, "tmp/uploads")
          @use_timestamp = false
        end
      end

    #TODO: modify this interpolation to account for styles
    ::Paperclip.interpolates :attachment_file_path do |asset, _|
      asset.instance.data_file_path
    end

    Paperclip.interpolates :attachments_root do |_, _|
      Attachment.configuration.attachments_root
    end

    Paperclip.interpolates :full_filename do |asset, _|
      "#{asset.instance.content_block_class}_#{asset.instance.data_file_name}"
    end

  end
end
