Then /^the image (\d+) should be moved to "([^"]*)"$/ do |image_block_id, section_name|
  image = Cms::ImageBlock.find(image_block_id.to_i)
  assert_equal section_name, image.parent.name
end

Then /^the image (\d+) should be at path "([^"]*)"$/ do |image_block_id, expected_path|
  image = Cms::ImageBlock.find(image_block_id.to_i)
  assert_equal expected_path, image.path
end

Then /^the following images exist:$/ do |table|
  table.hashes.each do |row|
    if row['section']
      row[:attachment_section_id] = Cms::Section.find_by_name(row.delete('section'))
    end
    b = create(:image_block, row)
    b.id = row['id']
    b.save!
  end
end

Then /^the following files exist:$/ do |table|
  table.hashes.each do |row|
    if row['section']
      row[:attachment_section_id] = Cms::Section.find_by_name(row.delete('section'))
    end
    b = create(:file_block, row)
    b.id = row['id']
    b.save!
  end
end

Then /^the following sections exist:$/ do |table|
  table.hashes.each do |row|
    create(:section, row)
  end
end

Then /^I should see an image with path "([^"]*)"$/ do |image_path|
  page.has_xpath? "//img[@src=\"#{image_path}\"]"
end

Then /^the attachment "([^"]*)" should be in section "([^"]*)"$/ do |asset_name, section_name|
  asset = Cms::Attachment.find_by_data_file_name asset_name
  asset.section.name.should == section_name
end

Then /^the attachment with path "([^"]*)" should be in section "([^"]*)"$/ do |asset_path, section_name|
  asset = Cms::Attachment.find_by_data_file_path asset_path
  asset.section.name.should == section_name
end

When /^I am adding a New Image$/ do
  visit '/cms/image_blocks/new'
end

Given /^an image with path "([^"]*)" exists$/ do |path|
  visit '/cms/image_blocks/new'
  fill_in "Name", :with => "Giraffe"
  fill_in "Path", :with => path
  attach_file "Image", "test/fixtures/giraffe.jpeg"
  click_button "true"
end

Given /^a file block with path "([^"]*)" exists$/ do |path|
  visit '/cms/file_blocks/new'
  fill_in "Name", :with => "Perspective"
  fill_in "Path", :with => path
  attach_file "File", "test/fixtures/perspective.pdf"
  click_button "true"
end

Then /^There should be a link to "([^"]*)"$/ do |path|
  page.has_xpath? "//a[@href=\"#{path}\"]"
end

When /^I am adding a new File$/ do
  visit '/cms/file_blocks/new'
end

When /^the file template should render$/ do
  within('#file_block_150') do
    assert page.has_content?('A Sample File')
  end
end
Given /^an image exists with two versions$/ do
  @image = create(:image_block, :name => "Image Version 1")
  @image.update_attributes(:name => "Version 2", :publish_on_save => true)

  @image.reload
  assert_equal 2, @image.version
end

When /^I revert the image to version 1$/ do
  visit "/cms/image_blocks/#{@image.id}"
  click_on "List Versions"
  # Select row (uses javascript)
  # Clicks 'revert button'
  page.driver.put "/cms/image_blocks/#{@image.id}/revert_to/1"
  visit "/cms/image_blocks/#{@image.id}"
end

Then /^the image should be reverted to version 1$/ do
  assert page.has_content? "Image Version 1"
end

When /^the image should be updated to version 3$/ do
  assert_equal 3, @image.as_of_draft_version.version
end

Given /^a file exists with two versions$/ do
  @original_file_name = "File Version 1"
  @file = create(:file_block, :name => @original_file_name, :attachment_file => mock_file(:original_filename => 'version1.txt'))

  visit "/cms/file_blocks/#{@file.id}/edit"
  attach_file "File", "test/fixtures/multipart/version2.txt"
  click_button "true"
end

When /^I view the first version of that file$/ do
  visit "/cms/file_blocks/#{@file.id}/version/1"
end

Then /^I should see the first version of the file$/ do
  click_on @original_file_name
  assert page.has_content?('v1')
  assert_equal 200, page.status_code
end

When /^I view the first version of that image$/ do
  visit "/cms/image_blocks/#{@image.id}/version/1"
end

Then /^I should see the first version of the image$/ do
  assert page.has_css?("img[data-type=image_block]")
  ele = page.first(:css, "img[data-type=image_block]")
  visit ele[:src]
  assert_equal 200, page.status_code
end

When /^I view that image on a page$/ do
  @page = create(:public_page)
  @image.reload
  @page.add_content(@image)
  @page.publish!

  visit @page.path
  #save_and_open_page
end

Then /^I should see the latest version of the image$/ do
  get_image("img[data-type=image_block]")
  assert_equal @image.file.data_file_path, current_path, "Should not be the login screen."
end