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
  assert page.has_css? "label", text: "Photo 1", :count => 1
  assert page.has_css? "label", text: "Photo 2", :count => 1
end

module MultipleAttachments
  def create_new_product(upload_both_files=true)
    visit '/cms/products/new'
    fill_in "Name", with: "Have two attachments"
    attach_file "Photo 1", "test/fixtures/giraffe.jpeg"
    attach_file "Photo 2", "test/fixtures/hurricane.jpeg" if upload_both_files
    click_button "Save"
  end
end
World(MultipleAttachments)

Given /^a block exists which configured to have two attachments$/ do
  register_content_type("Product")
  create_new_product
  @block = Product.last
end

When /^I edit that block$/ do
  visit "/cms/products/#{@block.id}/edit"
end

Given /^a block exists with two uploaded attachments$/ do
  register_content_type("Product")
  create_new_product
  @block = Product.last
end

When /^I replace both attachments$/ do
  visit "/cms/products/#{@block.id}/edit"
  attach_file "Photo 1", "test/fixtures/multipart/version1.txt"
  attach_file "Photo 2", "test/fixtures/multipart/version2.txt"
  click_button "Save"
end

Then /^I should see the new attachments when I view the block$/ do
  get_image("img[data-type=photo-1]")
  assert page.has_content?("v1"), "Check the contents of the image to make sure its the correct one."
  assert "/cms/attachments?version=2", current_path

end

When /^I upload a single attachment$/ do
  create_new_product(false)
  @block = Product.last
end