# ex: Then I should see a page titled "Home"
Then /^I should see a page titled "([^"]*)"$/ do |page_title|
  assert page.has_css?("title", :text=>page_title)
  assert page.has_content?(page_title)
end

Given /^I am logged in as a Content Editor$/ do
  visit '/cms'
  fill_in 'login', :with => 'cmsadmin'
  fill_in 'password', :with => 'cmsadmin'
  click_button 'LOGIN'
end

Given /^there is a LoginPortlet on the homepage$/ do
  cms_page = Cms::Page.with_path("/").first
  portlet = LoginPortlet.create!(:name=>"Login Portlet")
  cms_page.add_content(portlet, :main)
  cms_page.publish!
end


Then /^the homepage should exist$/ do
  cms_page = Cms::Page.with_path("/").first
  assert_not_nil cms_page
end

Then /^I should see Welcome, cmsadmin$/ do
  assert page.has_content? 'Welcome, cmsadmin'
end

Given /^I am at (.+)/ do |path|
  visit path
end

Then /^the response should be (.*)$/ do |response_code|
  assert_equal response_code.to_i, page.status_code
end

When /^login as an authorized user$/ do
  visit cms_login_path
  fill_in 'login', :with=>"privileged"
  fill_in 'password', :with=>"password"
  click_button 'LOGIN'
end
When /^I click the Select Existing Content button$/ do
  container = "main"
  click_link "insert_existing_content_#{container}"
end

When /^I turn on edit mode for (.*)$/ do |path|
  goto = path + "?mode=edit"
  visit(goto)
end

When /^I add new content to the page$/ do
  container = "main"
  click_link "Add new content to this container (#{container})"
end
Then /^I should see a list of selectable content types$/ do
  pending
end