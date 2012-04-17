module PageDiagnosticSteps
  def should_see_a_page_titled(page_title)
    assert page.has_css?("title", :text => page_title), "Expected a page with a title '#{page_title}'."
    assert page.has_content?(page_title)
  end
end
World(PageDiagnosticSteps)

# ex: Then I should see a page titled "Home"
Then /^I should see a page titled "([^"]*)"$/ do |page_title|
  should_see_a_page_titled(page_title)
end

When /^the page header should be "([^"]*)"$/ do |h1|
  assert page.has_css?("h1", :text => h1), "Expected to see <h1>#{h1}</h1> on the page."
end

When /^I am not logged in$/ do
  visit '/cms/logout'
end

Given /^I am logged in as a Content Editor(| on the admin subdomain)$/ do |is_admin|
  if is_admin.blank?
    login_at = '/cms/login'
  else
    login_at = 'http://cms.mysite.com/cms/login'
  end
  visit login_at
  fill_in 'login', :with => 'cmsadmin'
  fill_in 'password', :with => 'cmsadmin'
  click_button 'LOGIN'
end

Given /^there is a LoginPortlet on the homepage$/ do
  cms_page = Cms::Page.with_path("/").first
  portlet = LoginPortlet.create!(:name => "Login Portlet")
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

# Duplicates 'I request /path'
Given /^I am at (.+)/ do |path|
  visit path
end

Then /^the response should be (.*)$/ do |response_code|
  assert_equal response_code.to_i, page.status_code
end

When /^login as an authorized user$/ do
  visit "/cms/login"
  fill_in 'login', :with => "privileged"
  fill_in 'password', :with => "password"
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

When /^I click on "([^"]*)"$/ do |name|
  click_on name
end

When /^I am a guest$/ do
  visit '/cms/logout'
end


module PageNotFoundSteps
  def should_see_cms_404_page
    should_see_a_page_titled "Page Not Found"
    assert_equal 404, page.status_code
    assert page.has_content?("Page Not Found")
  end
end
World(PageNotFoundSteps)

Given /^there is a homepage$/ do
  page = Page.with_path("/").first
  if page
    @homepage = page
  else
    @homepage = create(:public_page, :path => "/", :name => "Home Page")
  end
end

Then /^I should see the CMS 404 page$/ do
  should_see_cms_404_page
end

Given /^a page at "([^"]*)" exists$/ do |path|
  page = create(:public_page, :path => path)
end

Given /^an archived page at "([^"]*)" exists$/ do |path|
  page = create(:page, :archived => true, :path => path)
  assert page.archived?
end

module ProtectedContentSteps
  def create_protected_user_section_group
    @protected_section = create(:section, :parent => root_section)
    @secret_group = create(:group, :name => "Secret")
    @secret_group.sections << @protected_section
    @privileged_user = create(:user, :login => "privileged")
    @privileged_user.groups << @secret_group
  end

  def create_protected_page(path="/secret")
    create_protected_user_section_group
    @page = create(:page,
                    :section => @protected_section,
                    :path => path,
                    :name => "Shhh... It's a Secret",
                    :template_file_name => "default.html.erb",
                    :publish_on_save => true)
  end

end
World(ProtectedContentSteps)

Given /^a protected page at "([^"]*)" exists$/ do |path|
  create_protected_page(path)
end

Then /^I should see the CMS :forbidden page$/ do
  assert_equal 403, page.status_code
  should_see_a_page_titled("Access Denied")
end

Given /^I am adding a page to the root section$/ do
  section = Cms::Section.root.first
  visit "/cms/sections/#{section.id}/pages/new"
end
When /^I am adding a link on the sitemap$/ do
  section = Cms::Section.root.first
  visit "/cms/sections/#{section.id}/links/new"
end
When /^I edit that link$/ do
  link = Cms::Link.first
  visit "/cms/links/#{link.id}/edit"
end

Given /^the following link exists:$/ do |table|
  table.hashes.each do |row|
    section = Cms::Section.with_path(row.delete('section')).first
    row['section_id'] = section.id
    create(:link, row)
  end
end

When /^I change the link name to "([^"]*)"$/ do |new_name|
  fill_in "Name", :with=>new_name
  click_on "Save And Publish"
end

When /^(?:a guest|I) visits* "([^"]*)"$/ do |url|
  visit url
end

When /^a registered user visits "([^"]*)"$/ do |url|
  registered_user = create(:registered_user)
  login_as(registered_user.login, registered_user.password)
  visit url
end


Then /^they should be redirected to "([^"]*)"$/ do |expected_url|
  assert_equal expected_url, current_url
end


Given /^a page exists with two versions$/ do
  @content_page = create(:public_page)
  @content_page.update_attributes(:name => "Version 2")
end

When /^I view the toolbar for version (\d+) of that page$/ do |version|
  visit "/cms/toolbar?page_id=#{@content_page.id}&page_toolbar=1&page_version=#{version}"
end

Then /^the toolbar should display a revert to button$/ do
  assert_equal 200, page.status_code
  assert page.has_content? "Revert to this Version"
end