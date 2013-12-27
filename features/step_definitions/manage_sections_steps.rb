Given /^I am adding a section to the root section$/ do
  section = Cms::Section.root.first
  visit "/cms/sections/new?section_id=#{section.id}"
end

When /^I create a public section$/ do
  fill_in "Name", :with=>  "A New Section"
  fill_in "Path", :with=>  "/my-new-section"
  ["Content Editors", "Cms Administrators", "Guest"].each do |checkbox|
    check checkbox
  end
  click_save_button
end

When /^the new section should be accessible to everyone$/ do
  section = Cms::Section.last
  assert_equal Cms::Group.count, section.groups.size
end