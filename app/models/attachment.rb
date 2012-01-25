require 'digest/sha1'
require 'fileutils'

class Attachment < ActiveRecord::Base

  #----- Constants ----------------------------------------------------------------
  UNKNOWN_MIME_TYPE = 'application/octet-stream'

  #----- Macros ----------------------------------------------------------------

  is_archivable
  is_publishable
  uses_soft_delete
  is_userstamped
  is_versioned

  # Rails 3 uses a new ActionDispatch::Http::UploadedFile. This holds that during the file processing.
  attr_accessor :uploaded_file

  # This exists for backwards compatibility
  alias_method :temp_file, :uploaded_file
  alias_method :temp_file=, :uploaded_file=

  #----- Callbacks -------------------------------------------------------------
  before_validation :make_dirty_if_temp_file
  before_validation :prepend_file_path_with_slash
  before_validation :extract_file_extension_from_file_name
  before_validation :extract_file_type_from_temp_file
  before_validation :extract_file_size_from_temp_file
  before_validation :set_file_location

  after_save :write_temp_file_to_storage_location
  after_save :clear_ivars  


  #----- Associations ----------------------------------------------------------

  include Addressable
  include Addressable::DeprecatedPageAccessors
  has_one :section_node, :as => :node
  alias :node :section_node

  #----- Validations -----------------------------------------------------------

  validates_presence_of :temp_file, :message => "You must upload a file", :on => :create
  validates_presence_of :file_path
  validates_uniqueness_of :file_path

  def section=(section)
    dirty! if self.section != section
    super(section)
  end
  #----- Callbacks Methods -----------------------------------------------------
  
  def make_dirty_if_temp_file
    dirty! if temp_file
  end
  
  def prepend_file_path_with_slash    
    unless file_path.blank?
      self.file_path = "/#{file_path}" unless file_path =~ /^\//
    end
  end
  
  def extract_file_extension_from_file_name
    if file_name && file_name['.']
      self.file_extension = file_name.split('.').last.to_s.downcase
    end    
  end
  
  def extract_file_type_from_temp_file
    unless temp_file.blank?
      self.file_type = temp_file.content_type

      # Some
      if self.file_type == nil
        self.file_type = UNKNOWN_MIME_TYPE
      end
    end    
  end
  
  def extract_file_size_from_temp_file  
    unless temp_file.blank?
      self.file_size = temp_file.size
    end    
  end

  # The file will be stored on disk at 
  # Attachment.storage_location/year/month/day/sha1
  # The sha1 is a 40 character hash based on the original_filename
  # of the file uploaded and the current time
  def set_file_location
    unless temp_file.blank?
      sha1 = Digest::SHA1.hexdigest("#{temp_file.original_filename}#{Time.now.to_f}")
      self.file_location = "#{Time.now.strftime("%Y/%m/%d")}/#{sha1}"
    end
  end

  #def process_section
  #  if section_node
  #    section_node.move_to_end(parent)
  #  #end
  #  #logger.info "processing section, section_id => #{section_id}, section_node => #{section_node.inspect}"
  #  #if section_node && !section_node.new_record? && section_node.section_id != section_id
  #  #  section_node.move_to_end(Section.find(section_id))
  #  else
  #    build_section_node(:node => self, :parent => parent)
  #  end
  #end
    
  def write_temp_file_to_storage_location
    unless temp_file.blank?
      actual_temp_file = temp_file.tempfile

      Rails.logger.warn "I want to write out #{temp_file.tempfile}"
      FileUtils.mkdir_p File.dirname(full_file_location)
      if actual_temp_file.path
        FileUtils.copy actual_temp_file.path, full_file_location
      else
        open(full_file_location, 'w') {|f| f << actual_temp_file.read }
      end
      
      if Cms.attachment_file_permission
        FileUtils.chmod Cms.attachment_file_permission, full_file_location
      end
    end
  end  
  
  def clear_ivars
    @temp_file = nil
    @section = nil
    @section_id = nil
  end
  
  #----- Class Methods ---------------------------------------------------------
  
  def self.storage_location
    @storage_location ||= File.join(Rails.root, "/tmp/uploads")
  end
  
  def self.storage_location=(storage_location)
    @storage_location = storage_location
  end  
  
  def self.find_live_by_file_path(file_path)
    Attachment.published.not_archived.first(:conditions => {:file_path => file_path})
  end  
  
  #----- Instance Methods ------------------------------------------------------

  def file_name
    file_path ? file_path.split('/').last : nil
  end

  def name
    file_name
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
      return icon if extensions.include?(file_extension.to_s)
    end
    :file
  end

  def public?
    section ? section.public? : false
  end
  
  def full_file_location
    File.join(Attachment.storage_location, file_location)
  end

  # Forces this record to be changed, even if nothing has changed
  # This is necessary if just the section.id has changed, for example
  def dirty!
    # Seems like a hack, is there a better way?
    self.updated_at = Time.now
  end

end