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
  visit "/cms/#{@block.class.path_name}/#{@block.id}/edit"
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

When /^I am created a new block which allows many attachments$/ do
  register_content_type("Catalog")
  visit '/cms/catalogs/new'
end

Then /^I should see the attachment manager widget displayed$/ do
  [
      'Upload a new attachment',
      'Attachment type',
      'Choose file'
  ].each do |words|
    page_should_have_content(words)
  end
end

Given /^a multi-attachment block exists with a single image$/ do
  @block = Catalog.create!(:name=>"Hello")
  @block.attachments << create(:attachment_document, :attachment_name => "photos", :attachable_type => "Catalog")
  @block.save!
end

When /^I view that block$/ do
  path = "/cms/#{@block.class.path_name}/#{@block.id}"
  assert_equal "/cms/catalogs/1", path
  visit path
end

Then /^I should see that block's image$/ do
  assert page.has_css?("img[data-purpose=attachment]")
end

When /^I (#{SHOULD_OR_NOT}) see the delete attachment link$/ do |should_see|
  within("#assets_table") do
    assert_equal should_see, page.has_css?("a", :text=>"Delete")
  end
end