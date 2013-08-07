# Steps for portlet.features
When /^I delete that portlet$/ do
  # cms_portlet_path(@subject) seemed to create a wrong path: /cms/portlets.1 rather than the below statement
  page.driver.delete "/cms/portlets/#{@subject.id}"
end

# Why oh why does path lookup with engines not work (i.e. want to say portlet_path(@subject))
When /^I view that portlet$/ do
  visit "/cms/portlets/#{@subject.id}"
end

When /^I edit that portlet$/ do
  visit cms.edit_portlet_path(@subject)
end

When /^I visit that page$/ do
  assert_not_nil @last_page, "Couldn't find @last_page to visit. Check the order on steps'"
  visit @last_page.path
end


Given /^a page with a portlet that raises a Not Found exception exists$/ do
  @last_page = create(:public_page)
  @raises_not_found = create(:portlet, :code => 'raise ActiveRecord::RecordNotFound', :template => "I shouldn't be shown.'")
  @last_page.add_content(@raises_not_found)
  @last_page.publish!
  assert @last_page.published?
end

When /^a page with a portlet that raises an Access Denied exception exists$/ do
  @last_page = create(:public_page)
  @raises_access_denied = create(:portlet, :code => 'raise Cms::Errors::AccessDenied', :template => "I shouldn't be shown.'")
  @last_page.add_content(@raises_access_denied)
  @last_page.publish!
  assert @last_page.published?
end

When /^a page with a portlet that display "([^"]*)" exists$/ do |view|
  @last_page = create(:public_page)
  portlet = create(:portlet, :template => view)
  @last_page.add_content(portlet)
  @last_page.publish!
  assert @last_page.published?
end

When /^a page with a portlet that raises both a 404 and 403 error exists$/ do
  @last_page = create(:public_page)
  @raises_not_found = create(:portlet, :code => 'raise ActiveRecord::RecordNotFound', :template => "I shouldn't be shown.'")
  @last_page.add_content(@raises_not_found)
  @raises_access_denied = create(:portlet, :code => 'raise Cms::Errors::AccessDenied', :template => "I shouldn't be shown.'")
  @last_page.add_content(@raises_access_denied)
  @last_page.publish!
  assert @last_page.published?
end

When /^a page with a portlet that raises both a 403 and any other error exists$/ do
  @last_page = create(:public_page)
  @raises_not_found = create(:portlet, :code => 'raise "A Generic Error"', :template => "I shouldn't be shown.'")
  @last_page.add_content(@raises_not_found)
  @raises_access_denied = create(:portlet, :code => 'raise Cms::Errors::AccessDenied', :template => "I shouldn't be shown.'")
  @last_page.add_content(@raises_access_denied)
  @last_page.publish!
  assert @last_page.published?
end

Given /^a portlet that throws an unexpected error exists$/ do
  @page = create(:public_page)
  @portlet_render = DynamicPortlet.create!(:name => "Test", :connect_to_page_id => @page.id, :connect_to_container => "main", :template => '<p id="hi">hello</p>')
  @portlet_raise_generic = DynamicPortlet.create!(:name => "Test", :connect_to_page_id => @page.id, :connect_to_container => "main", :code => 'raise Exception')
  @page.publish!
end
Given /^there is a portlet that uses a helper$/ do
  @page_path = "/with-helper"
  @portlet = create(:portlet_with_helper, page_path: @page_path)

end
When /^I view that page$/ do
  if (@page_path)
    visit @page_path
  else
    visit most_recently_created_page.path
  end

end

Then /^I should see the portlet helper rendered in the view$/ do
  assert page.has_content?(UsesHelperPortletHelper::EXPECTED_CONTENT)
end

Given /^a developer creates a portlet which sets a custom page title as "([^"]*)"$/ do |title|
  @page_path = "/portlet/custom-page-title"
  @portlet = create(:portlet_with_helper, page_path: @page_path, custom_title: title)
end

When /^a guest views that page$/ do
  logout
  visit @page_path
end

Then /^the page should show content but not the error$/ do
  refute page.has_content?('Exception'), "Exception should not appear on the page"
  refute page.has_content?('Error'), "The word 'Error' should not appear on the page"
  assert page.has_content?('hello'), "Should see other content"
  should_see_a_page_titled(most_recently_created_page.title)
end