Then /^I should see the following content:$/ do |table|
  table.raw.each do |row|
    assert page.has_content?(row[0]), "Couldn't find #{row[0]}' anywhere on the page."
  end
end

# Creates a CMS::FileBlock
Given /^a text file named "([^"]*)" exists with:$/ do |file_name, text|
  tempfile = Tempfile.new file_name do |f|
    f << text
  end
  tempfile << text
  tempfile.flush
  tempfile.close

  upload_file = Rack::Test::UploadedFile.new(tempfile.path, "text/plain", false)
  Factory(:file_block, :attachment_file => upload_file, :attachment_file_path => file_name)
end

When /^I request (.*)$/ do |path|
  visit path
end