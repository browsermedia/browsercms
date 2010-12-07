module Cms

  # Simplified handling for creating files for writing tests around multipart uploads.
  module MockFile
    FILES_DIR = File.dirname(__FILE__) + '/fixtures/multipart'

    # Creates a file to test uploading to a sample file.
    def self.new_file(file_name='foo.jpg', content_type="image/jpeg")
      Rack::Test::UploadedFile.new("#{FILES_DIR}/#{file_name}", content_type, false)
    end
  end

  # For activating logging on the console 
  def self.activate_logging
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
end