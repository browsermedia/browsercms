When /^I am editing at page$/ do
  @editing_page = create(:public_page)
  visit(@editing_page.path)
end

When /^I press the 'New' menu button$/ do
  click_on 'New'
end

Then /^it should add a page in the same section I as the page I was editing$/ do
  should_see_a_page_titled("New Page")
end