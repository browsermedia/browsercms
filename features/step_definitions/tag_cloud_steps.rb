When /^the a block exist that are tagged with "([^"]*)"$/ do |tag|
  block = create(:html_block)
  block.tags << Cms::Tag.named(tag).first
  block.save!
end

When /^the following tags exist:$/ do |table|
  table.hashes.each do |row|
    Cms::Tag.create!(row)
  end
end