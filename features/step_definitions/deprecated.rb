Given /^we are using a Rails 4.0 compatible version of cucumber$/ do
  pending
end

Given /^I'm creating content which uses deprecated input fields$/ do
  visit new_cms_deprecated_input_path
end

Then /^the form page with deprecated fields should be shown$/ do
  assert_equal 200, page.status_code.to_i
end

When /^I fill in all the deprecated fields$/ do
  fill_in "Name", with: @expect_name = "Expected Name"
  fill_in "Content", with: @expect_content = "Expected Content"
  fill_in "Template", with: @expect_template = "Expected Template"
  attach_file "Cover Photo", "test/fixtures/#{@expect_file_name = 'giraffe.jpeg'}"
  click_button "Save And Publish"
end

Then /^a new deprecated content block should be created$/ do
  should_be_successful
  last_block = DeprecatedInput.last
  assert_not_nil last_block, "Content should have been created."
  assert_equal @expect_name, last_block.name
  assert_equal @expect_content, last_block.content
  assert_equal @expect_template, last_block.template
  assert_equal @expect_file_name, last_block.cover_photo.file_name
end