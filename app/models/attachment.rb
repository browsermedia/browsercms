class Attachment < ActiveRecord::Base

  #----- Callbacks -------------------------------------------------------------

  before_validation :process_file
  before_validation :process_section
  before_validation :prepend_slash
  before_save :update_file
  after_save :write_file
  after_save :clear_ivars  
  
  #----- Macros ----------------------------------------------------------------

  uses_soft_delete
  is_userstamped
  is_versioned
  attr_accessor :file

  #----- Associations ----------------------------------------------------------

  has_one :section_node, :as => :node
  belongs_to :attachment_file

  #----- Validations -----------------------------------------------------------

  validates_presence_of :file_name
  validates_presence_of :file_size, :message => "You must upload a file"
    
  #----- Virtual Attributes ----------------------------------------------------
  
  def section_id
    @section_id ||= section_node ? section_node.section_id : nil
  end

  def section_id=(section_id)
    @section_id = section_id
  end

  def section
    @section ||= section_node ? section_node.section : nil
  end

  def section=(section)
    @section_id = section ? section.id : nil
    @section = section
  end
  
  #----- Callbacks Methods -----------------------------------------------------
  
  def process_file
    unless file.blank? || file.size.to_i < 1
      unless file_name.blank? || !file_name['.']
        self.file_extension = file_name.split('.').last.to_s.downcase
      end
      self.file_type = file.content_type
      self.file_size = file.size
    end
  end

  def process_section
    if section_id
      if section_node && !section_node.new_record? && section_node.section_id != section_id
        section_node.move_to_end(Section.find(section_id))
      else
        build_section_node(:node => self, :section_id => section_id)
      end    
    end
  end
  
  def prepend_slash    
    self.file_name = "/#{file_name}" unless file_name =~ /^\//
    self.file_name = nil if file_name.strip == "/"
  end  

  def update_file
    unless file.blank? || file.size.to_i < 1
      file.rewind      
      create_attachment_file(:data => file.read)
      self.file = nil    
    end
  end
  
  def write_file
    if archived? || deleted?
      logger.info "Deleting #{absolute_path}"
      FileUtils.rm_f File.dirname(absolute_path)
    elsif published?
      FileUtils.mkdir_p File.dirname(absolute_path)
      logger.info "Writing out #{absolute_path}"
      open(absolute_path, "wb") {|f| f << data }
    end
  end  
  
  def clear_ivars
    @section = nil
    @section_id = nil
  end
  
  #----- Class Methods ---------------------------------------------------------
  
  def self.find_live_by_file_name(file_name)
    page = find(:first, :conditions => {:file_name => file_name})
    page ? page.live_version : nil
  end  
  
  #----- Instance Methods ------------------------------------------------------

  #This is just the name part of the file_name.
  #Example, file_name (the column in the database), will be /foo/bar.pdf,
  #this will return bar.pdf
  def name
    file_name.blank? ? nil : file_name.split("/").last
  end
  
  def live?
    versionable? ? versions.count(:conditions => ['version > ? AND published = ?', version, true]) == 0 && published? : true
  end

  def live_version
    if archived? || deleted?
      nil
    elsif published?
      self
    else
      live_version = versions.first(:conditions => {:published => true}, :order => "version desc, id desc")
      live_version ? as_of_version(live_version.version) : nil
    end                
  end  
  
  def data
    attachment_file.data
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

  def absolute_path
    File.join(ActionController::Base.cache_store.cache_path, file_name)
  end

end