class Attachment < ActiveRecord::Base

  before_validation :process_file
  before_save :update_file
  
  version_fu
  is_paranoid
  
  attr_accessor :file

  has_one :section_node, :as => :node

  belongs_to :attachment_file

  after_save :write_file
  after_destroy :delete_file
  
  validates_presence_of :file_name
  validates_presence_of :file_size, :message => "You must upload a file"
  
  #This is just the name part of the file_name.
  #Example, file_name (the column in the database), will be /foo/bar.pdf,
  #this will return bar.pdf
  def name
    file_name.blank? ? nil : file_name.split("/").last
  end
  
  def section_id
    section ? section.id : nil
  end

  def section
    section_node ? section_node.section : nil
  end

  def section_id=(sec_id)
    self.section = Section.find(sec_id)
  end

  def section=(sec)
    if section_node
      section_node.move_to_end(sec)
    else
      build_section_node(:node => self, :section => sec)
    end      
  end
  
  def self.find_by_path(path)
    find(:first, :conditions => {:file_name => path})
  end

  def process_file
    unless file.blank? || file.size.to_i < 1
      unless file_name.blank? || !file_name['.']
        self.file_extension = file_name.split('.').last.to_s.downcase
      end
      self.file_type = file.content_type
      self.file_size = file.size
    end
  end

  def update_file
    unless file.blank? || file.size.to_i < 1
      file.rewind      
      create_attachment_file(:data => file.read)
      self.file = nil    
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

  def write_file
    FileUtils.mkdir_p File.dirname(absolute_path)
    logger.info "Writing out #{absolute_path}"
    open(absolute_path, "wb") {|f| f << data }
  end

end