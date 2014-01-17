require 'cms/data_loader'

require File.expand_path(File.join(__FILE__, "..", "..", "..", "test", "mock_file"))
module FileOperations

  # @deprecated Use FactoryGirl.create(:file_block) directly instead of this whereever possible.
  #
  # Creates an 'uploaded' file block at a given relative path
  # @param [String] relative_file_path A relative file path (i.e. /test.txt) for the uploaded block.
  def create_file(relative_file_path, text="Test Content", section=nil)
    # We are creating a temp file with no path, so strip leading slash
    file_name, upload_file = text_file(relative_file_path, text)
    options = {:attachment_file => upload_file, :attachment_file_path => file_name}
    options[:parent] = section if section
    FactoryGirl.create(:file_block, options)
  end

  def text_file(relative_file_path, text)
    file_name = relative_file_path.gsub(/^\//, "")
    tempfile = Tempfile.new file_name
    tempfile << text
    tempfile.flush
    tempfile.close

    upload_file = Rack::Test::UploadedFile.new(tempfile.path, "text/plain", false)
    return file_name, upload_file
  end
end

World(FileOperations)


