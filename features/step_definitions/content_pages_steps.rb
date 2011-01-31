# ex: Then I should see a page titled "Home"
Then /^I should see a page titled "([^"]*)"$/ do |page_title|
  page.has_css? "title", :text=>page_title
end

Given /^I am logged in as a Content Editor$/ do
  visit '/cms'
  fill_in 'login', :with => 'cmsadmin'
  fill_in 'password', :with => 'cmsadmin'
  click_button 'LOGIN'
end

Given /^there is a LoginPortlet on the homepage$/ do
  cms_page = Page.with_path("/").first
  portlet = LoginPortlet.new(:name=>"Login Portlet")
  cms_page.add_content(portlet)
end

Then /^I should see a Login Form$/ do
  page.has_selector?('form')
  page.has_content?('action="/cms/login"')
  page.has_content? 'Login'
  page.has_content? 'Password'
end

Then /^the homepage should exist$/ do
  cms_page = Page.with_path("/").first
  cms_page.should_not be_nil
end

Given /^there is a homepage$/ do
  @homepage = Factory(:page, :path=>"/", :name=>"Home Page")
end
Then /^I should see Welcome, cmsadmin$/ do
  page.has_content? 'Welcome, cmsadmin'
end