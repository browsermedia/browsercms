Then /^I should see a label named "([^"]*)"$/ do |label_name|
  assert page.has_css? "label", text: label_name
end

When /^I should see a file upload button$/ do
  assert page.has_css? "input[type=file]"
end

When /^I should see the following instructions:$/ do |table|
  table.rows.each do |text|
    assert page.has_css? ".instructions", text: text
  end
end

Given /^I am creating a new block which has two attachments$/ do
  register_content_type("Product")
  visit '/cms/products/new'
end

Then /^I should see two file uploads$/ do
  assert page.has_css? "label", text: "Photo 1", :count=>1
  assert page.has_css? "label", text: "Photo 2", :count=>1
end

Given /^a block exists with two attachments$/ do
  register_content_type("Product")
  visit '/cms/products/new'
  fill_in "Name", with: "Have two attachments"
  attach_file "Photo 1", "test/fixtures/giraffe.jpeg"
  attach_file "Photo 2", "test/fixtures/hurricane.jpeg"
  click_button "Save"

  @block = Product.last
end

When /^I edit that block$/ do
  visit "/cms/products/#{@block.id}/edit"
end