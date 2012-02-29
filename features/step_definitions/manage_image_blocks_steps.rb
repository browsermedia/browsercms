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

