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

module Extensions
  module Rack
    module Test
      # Extensions to make Rack::Test::UploadedFile function like ActionDispatch::Http::UploadedFile during unit/functional tests.
      module UploadedFile

        # Attachment relies on this being there
        def tempfile
          @tempfile
        end
      end
    end
  end
end
Rack::Test::UploadedFile.send(:include, Extensions::Rack::Test::UploadedFile)