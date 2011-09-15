Then /^I should see the CKEditor$/ do
  assert page.has_css?('script', :src=>"/bcms/ckeditor/ckeditor.js"), "Should include the ckeditor file"
  assert page.has_css?('script', :src=>"/bcms/ckeditor/editor.js"), "Should include the ckeditor file"
end