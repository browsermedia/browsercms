# ex: Then I should see a page named "Home"
Then /^I should see a page named "([^"]*)"$/ do |page_title|
  should_see_a_page_title_and_header(page_title)
end

Then /^I should see a page titled "([^"]*)"$/ do |page_title|
  should_see_a_page_titled(page_title)
end

Then /^I should see a page with a header "([^"]*)"$/ do |page_header|
  should_see_a_page_header(page_header)
end

When /^the page header should be "([^"]*)"$/ do |h1|
  assert page.has_css?("h1", :text => h1), "Expected to see <h1>#{h1}</h1> on the page."
end

When /^I am not logged in$/ do
  logout
end

Given /^I am visiting as a guest$/ do
  logout
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

When /^I am editing the page at (#{PATH})$/ do |path|
  @last_page = Cms::Page.with_path(path).first
  visit cms.edit_content_path(@last_page)
end

# Uses direct link rather than clicking which requires Javascript driver to do.
When /^I choose to reuse content$/ do
  visit cms.new_connector_path(container: 'main', page_id: @last_page.id)
end

# Uses direct link rather than clicking which requires Javascript driver to do.
When /^I choose to add a new 'Text' content type to the page$/ do
  visit cms.new_html_block_path('html_block[connect_to_container]' => 'main', 'html_block[connect_to_page_id]' => @last_page.id)
end

When /^I turn on edit mode for (.*)$/ do |path|
  goto = path + "?mode=edit"
  visit(goto)
end

When /^I add new content to the page$/ do

  #container = "main"
  #click_link "Add new content to this container (#{container})"
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

Given /^a protected page at "([^"]*)" exists$/ do |path|
  create_protected_page(path)
end

Then /^I should see the CMS :forbidden page$/ do
  assert_equal 403, page.status_code
  should_see_a_page_title_and_header("Access Denied")
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
  fill_in "Name", :with => new_name
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

When /^I view version (\d+) of that page$/ do |version|
  visit cms.version_cms_page_path(id: @content_page.id, version: version)
end

Then /^the toolbar should display a revert to button$/ do
  assert_equal 200, page.status_code
  assert((page.has_content? "Revert to this Version"), "The Page toolbar does not display the revert to button.")
end

When /^the page content should contain "([^"]*)"$/ do |content|
  within_content_frame do
    assert page.has_content?(content)
  end
end

When /^I create a new page$/ do
  visit '/cms/sections/1/pages/new'
  fill_in "Name", with: "New Page"
  fill_in "Path", with: "/new-page"
  click_on 'Save'
end

Then /^that page should not be published$/ do
  refute most_recently_created_page.published?, "The page should not be published."
end

Then /^I publish that page$/ do
  visit most_recently_created_page.path
  click_put_link "Publish"
end

Then /^that page should be published$/ do
  assert most_recently_created_page.published?, "The page should be published."
end

Then /^I should end up on that page$/ do
  should_see_a_page_title_and_header(most_recently_created_page.title)
end

Then /^the page frame should contain the following:$/ do |table|
  within_frame 'page_content' do
    table.rows.each do |row|
      assert page.has_content? row[0]
    end
  end
end

Then /^I should the content rendered inside the editor frame$/ do
  assert page_has_editor_iframe?()
end
Then /^I should return to List Users$/ do
  should_see_a_page_header 'List Users'
end

Then /^I should see the Home page$/ do
  should_see_a_page_titled 'Home'
end

Then /^I should see the View Text page$/ do
  should_see_a_page_titled "Content Library / View Text"
end
When /^choose to view "([^"]*)" from the main menu$/ do |arg|
  within('#content-library-menu') do
    click_link arg
  end
end

When /^I clear the page cache$/ do
  find(:rel, 'clear-cache').click
end
Given /^that a page I want to edit exists$/ do
  @page_to_edit = create(:page, parent: root_section)
end

Given /^I go to the sitemap$/ do
  visit cms.sitemap_path
end

# Ideally would use sitemap buttons to interact, but that requires javascript
When /^I select the page to edit$/ do
  visit cms.edit_page_path(@page_to_edit)
end
When /^I change the page name$/ do
  @expected_new_name = "A New Page Name"
  fill_in "Name", with: @expected_new_name
  click_on "Save"
end
Then /^I should be returned to that page$/ do
  assert_equal 200, page.status_code
  assert_equal @page_to_edit.path, current_path
end
When /^I should see the new page name$/ do
  should_see_a_page_titled @expected_new_name
end

Given /^I am adding a new tag$/ do
  visit cms.new_tag_path
end