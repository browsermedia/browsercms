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

Given /^there is an Html Block with:$/ do |table|
  Factory(:html_block, table.hashes.first)
end

# When there is a 'Portlet' with:
# | name | content |
# | A    |    B    |
When /^there is a "([^"]*)" with:$/ do |model_class, table|
  Factory(model_class.underscore.to_sym, table.hashes.first)
end

When /^there is a page with:$/ do |table|
  Factory(:public_page, { :publish_on_save=>true }.merge(table.hashes.first))
end