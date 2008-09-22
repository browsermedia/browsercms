class CmsAbstractFile < ActiveRecord::Base
  set_table_name "cms_files"
  
  attr_accessor :file

  belongs_to :cms_file_datum

  before_save :process_file
  before_update :delete_file
  after_destroy :delete_file


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
    
      create_cms_file_datum(:data => file.read)
    end
  end
  
  def data
    cms_file_datum.data
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
end