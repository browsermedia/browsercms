require 'cms/data_loader'


module LaunchBrokenTests
  LAUNCH = false
  def launch_broken_tests
    LAUNCH
  end
end
World(LaunchBrokenTests)

After do |scenario|
  if scenario.failed? && launch_broken_tests
    save_and_open_page
  end
end

AfterConfiguration do |config|
  if config.formats[0].include?("Debug::Formatter")
    LaunchBrokenTests::LAUNCH = true
  end
end


require File.expand_path(File.join(__FILE__, "..", "..", "..","test", "mock_file"))
module FileOperations

  def create_file(file_name, text="Test Content")
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

# Make sure the database is completely empty before we start, then go back to cleaning up between transactions.
DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction

