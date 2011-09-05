require 'cms/data_loader'

After do |scenario|
  #save_and_open_page if scenario.failed?
end

require "#{Rails.root}/test/mock_file"

module FileOperations

  def create_file(file_name, text)
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

