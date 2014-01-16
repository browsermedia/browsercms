# ex: Then I should see a page named "Home"
Then /^I should see a page named "([^"]*)"$/ do |page_title|
  should_see_a_page_named(page_title)
end

Then /^I should see a page titled "([^"]*)"$/ do |page_title|
  should_see_a_page_titled(page_title)
end

Then /^I should see a page with a header "([^"]*)"$/ do |page_header|
  should_see_a_page_header(page_header)
end

When /^the page header should be "([^"]*)"$/ do |h1|
  should_see_a_page_header(h1)
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
  login_as('cmsadmin', 'cmsadmin', login_at)
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
  login_as('privileged', 'password')
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


When /^I click the Save button$/ do
  click_save_button
end

When /^I click the Publish button$/ do
  click_publish_button
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
  should_see_a_page_named("Access Denied")
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
  click_publish_button
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
  visit cms.version_page_path(id: @content_page.id, version: version)
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
  fill_in "page_name", with: "New Page"
  fill_in "Path", with: "/new-page"
  find('.top-buttons').click_on 'Save'
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
  should_see_a_page_titled(most_recently_created_page.title)
end

Then /^the page frame should contain the following:$/ do |table|
  within_frame 'page_content' do
    table.rows.each do |row|
      assert page.has_content? row[0]
    end
  end
end

Then /^I should the content rendered inside the editor frame$/ do
  assert page_has_editor_iframe?
end

Then /^I should return to List Users$/ do
  should_see_a_page_header 'Users'
end

Then /^I should see the Home page$/ do
  should_see_a_page_titled 'Home'
end

Then /^I should see the View Text page$/ do
  should_see_a_page_titled "Text"
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
  fill_in "page_name", with: @expected_new_name
  click_save_button
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

Given /^I had created a form named "([^"]*)"$/ do |arg|
  create(:form, name: arg)
end

When /^I select forms from the content library$/ do
  visit cms.forms_path
end

Given /^I am on the Groups page$/ do
  visit cms.groups_path
  should_see_a_page_titled "Groups"
end

Then(/^I should see the list of forms$/) do
  should_be_successful
  should_see_a_page_titled('Forms')
end

Then(/^I should see the "([^"]*)" form in the list$/) do |form_name|
  page_should_have_content(form_name)
end

When /^I am adding new form$/ do
  visit cms.new_form_path
end

When(/^I enter the required form fields$/) do
  fill_in "Name", with: "Contact Us"
  click_publish_button
end

Then(/^after saving I should be redirect to the form page$/) do
  should_be_successful
  should_see_a_page_titled "Contact Us"
end

When(/^I edit that form$/) do
  @form = Cms::Form.where(name: "Contact Us").first
  visit cms.edit_form_path(@form)
end

When(/^I make changes to the form$/) do
  fill_in "Name", with: "Updated Name"
  click_publish_button
end

Then(/^I should see the form with the updated fields$/) do
  should_be_successful
  should_see_a_page_titled "Updated Name"
end

Then /^I should be returned to the Assets page for "([^"]*)"$/ do |content_type|
  should_see_a_page_named("Assets")
  asset_selector_button.has_content?(content_type)
end

Then /^I should see the login portlet form$/ do
 steps %Q{ Then I should see the following content:
    | Login       |
    | Password    |
    | Remember me |
  }
end
When /^the content should be published$/ do
  page_should_have_content 'Published'
end

When /^I click Change Password for user "([^"]*)"$/ do |user_name|
  find(:xpath, "//tr[contains(.,'#{user_name}')]/td/a", :text => 'Change Password').click
end