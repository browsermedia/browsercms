When /^I am editing at page$/ do
  @editing_page = create(:public_page)
  visit(@editing_page.path)
end

When /^I press the 'New' menu button$/ do
  click_on 'New'
end

Then /^it should add a page in the same section I as the page I was editing$/ do
  should_see_a_page_named("New Page")
end

Then /^it should add a page in the root section$/ do
  should_see_a_page_named("New Page")
end

When /^I am working with a content type$/ do
  visit("/cms/html_blocks")
end

Then /^it should add a new item of that type$/ do
  should_see_a_page_named("Add a New Text")
end

When /^I am managing users$/ do
  visit '/cms/users'
end

Then /^it should add a new user$/ do
  should_see_a_page_named "New User"
end
When /^I am managing groups$/ do
  visit '/cms/groups'
end
Then /^it should add a new redirect$/ do
  should_see_a_page_named "New Redirect"
end