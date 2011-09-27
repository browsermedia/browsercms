Then /^I should see the CKEditor$/ do
  assert page.has_css?('script', :src=>"/bcms/ckeditor/ckeditor.js"), "Should include the ckeditor file"
  assert page.has_css?('script', :src=>"/bcms/ckeditor/editor.js"), "Should include the ckeditor file"
end

Then /^I should see a widget to select which editor to use$/ do
  # This just verifies that the text editor selection widget is present.
  assert page.has_selector?('#dhtml_selector')
  within('#dhtml_selector') do
    assert page.has_content?("Rich Text")
    assert page.has_content?("Simple Text")
  end
end