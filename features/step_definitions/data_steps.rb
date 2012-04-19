

Then /^I should see the following content:$/ do |table|
  table.raw.each do |row|
    page_should_have_content(row[0])
  end
end

When /^I should not see the following content:$/ do |table|
  table.raw.each do |row|
    page_should_have_content(row[0], false)
  end
end


# Creates a CMS::FileBlock
Given /^a text file named "([^"]*)" exists with:$/ do |file_name, text|
  create_file(file_name, text)
end

Given /^a protected text file named "([^"]*)" exists with:$/ do |file_name, text|
  section = create(:protected_section)
  file = create_file(file_name, text, section)
end

Given /^an archived file named "([^"]*)" exists$/ do  |file_name|
  file = create(:file_block, :archived=>true, :attachment_file_path => file_name)
  assert file.archived?, "Verify the file I just created should be archived"
end

When /^I (?:request|visit) (#{PATH})$/ do |path|
  visit path
end

Given /^there is an Html Block with:$/ do |table|
  create(:html_block, table.hashes.first)
end

# When there is a 'Portlet' with:
# | name | content |
# | A    |    B    |
When /^there is a "([^"]*)" with:$/ do |model_class, table|
  @subject = create(model_class.underscore.to_sym, table.hashes.first)
end

When /^there is a page with:$/ do |table|
  create(:public_page, { :publish_on_save=>true }.merge(table.hashes.first))
end
