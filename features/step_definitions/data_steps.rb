Then /^I should see the following content:$/ do |table|
  table.raw.each do |row|
    assert page.has_content?(row[0]), "Couldn't find #{row[0]}' anywhere on the page."
  end
end

# Creates a CMS::FileBlock
Given /^a text file named "([^"]*)" exists with:$/ do |file_name, text|
  create_file(file_name, text)
end

Given /^a protected text file named "([^"]*)" exists with:$/ do |file_name, text|
  file = create_file(file_name, text)
  section = Factory(:protected_section)
  file.update_attributes(:attachment_section => section)
end

When /^I request (.*)$/ do |path|
  visit path
end