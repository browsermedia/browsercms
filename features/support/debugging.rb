require 'cms/data_loader'

require File.expand_path(File.join(__FILE__, "..", "..", "..", "test", "mock_file"))
module FileOperations

  # Creates an 'uploaded' file block at a given relative path
  # @param [String] relative_file_path A relative file path (i.e. /test.txt) for the uploaded block.
  def create_file(relative_file_path, text="Test Content")
    # We are creating a temp file with no path, so strip leading slash
    file_name = relative_file_path.gsub(/^\//, "")
    tempfile = Tempfile.new file_name do |f|
      f << text
    end
    tempfile << text
    tempfile.flush
    tempfile.close

    upload_file = Rack::Test::UploadedFile.new(tempfile.path, "text/plain", false)
    Factory(:file_block, :attachment_file => upload_file, :attachment_file_path => file_name)
  end
end

World(FileOperations)


