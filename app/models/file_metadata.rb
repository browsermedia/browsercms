class FileMetadata < ActiveRecord::Base
  attr_accessor :file

  belongs_to :file_binary_data
  belongs_to :section

  before_save :process_file
  after_save :write_file
  after_destroy :delete_file

  validates_presence_of :section_id

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

      create_file_binary_data(:data => file.read)
      
    end
  end

  def data
    file_binary_data.data
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
    File.join(ActionController::Base.cache_store.cache_path, section.path, "#{id}_#{file_name}")
  end

  def write_file
    FileUtils.mkdir_p File.dirname(absolute_path)
    open(absolute_path, "wb") {|f| f << data }
  end

end