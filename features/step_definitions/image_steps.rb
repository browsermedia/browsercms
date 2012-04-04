Then /^the section (\d+) should be moved to "([^"]*)"$/ do |image_block_id, section_name|
  assert_equal section_name, Cms::ImageBlock.find(image_block_id.to_i).parent.name
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

When /^I should see the section search filter$/ do
  terms = %w{
    All sections
    My Site
    system
  }
  terms.each do |text|
    assert page.has_content?(text)
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
  attach_file "File", "test/fixtures/giraffe.jpeg"
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