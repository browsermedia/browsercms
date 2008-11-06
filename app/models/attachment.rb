class Attachment < ActiveRecord::Base
  attr_accessor :file

  belongs_to :attachment_file
  belongs_to :section

  before_save :process_file
  after_create :prepend_id_to_file_name
  after_save :write_file
  after_destroy :delete_file

  validates_presence_of :section_id

  named_scope(:with_path, lambda { |p| 
    paths = p.sub(/^\//,'').split("/")
    file_name = paths.slice!(-1)
    path = "/#{paths.join("/")}"
    {:include => :section, :conditions => ['sections.path = ? and attachments.file_name = ?', path, file_name]}
  })
  
  def self.find_by_path(path)
    with_path(path).first
  end

  def process_file
    unless file.blank? || file.size.to_i < 1
      self.file_name = file.original_filename
      unless file_name.blank?
        self.file_extension = file_name.split('.').last.to_s.downcase
      end
      self.file_type = file.content_type
      self.file_size = file.size

      #I think this is needed to return the StringIO to the beginning
      #because we have advanced it by looking at other values
      file.rewind

      create_attachment_file(:data => file.read)
      self.file = nil
    end
  end

  def updating_file!
    logger.info "Updating file"
    @_updating_file = true
  end

  def prepend_id_to_file_name
    if @_updating_file
      if m = file_name.match(/^\d+(_.*)/)
        new_file_name = "#{id}#{m[1]}"
      else
        new_file_name = file_name
      end
    else
      new_file_name = "#{id}_#{file_name}"
    end
    update_attribute(:file_name, new_file_name) 
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
    File.join(ActionController::Base.cache_store.cache_path, section.path, file_name)
  end

  def write_file
    FileUtils.mkdir_p File.dirname(absolute_path)
    logger.info "Writing out #{absolute_path}"
    open(absolute_path, "wb") {|f| f << data }
  end

end