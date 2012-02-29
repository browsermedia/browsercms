Then /^the section (\d+) should be moved to "([^"]*)"$/ do |image_block_id, section_name|
  assert_equal section_name, Cms::ImageBlock.find(image_block_id.to_i).parent.name
end

Then /^the following images exist:$/ do |table|
  table.hashes.each do |row|
    if row['section']
      row[:attachment_section_id] = Cms::Section.find_by_name(row.delete('section'))
    end
    b = Factory(:image_block, row)
    b.id = row['id']
    b.save!
  end
end

Then /^the following sections exist:$/ do |table|
  table.hashes.each do |row|
    Factory(:section, row)
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
