When /^there are some additional pages and sections$/ do
  @foo = create(:section, :name => "Foo", :parent => root_section)
  @bar = create(:section, :name => "Bar", :parent => @foo)
  @page = create(:page, :name => "Test Page", :section => @bar)
end
Then /^I should see the new pages and sections$/ do
  assert page.has_content?("Foo")
  assert page.has_content?("Bar")
  assert page.has_content?("Test Page")

end
When /^I should see the stock CMS pages$/ do
  assert page.has_content?("My Site")
  assert page.has_content?("system")
  assert page.has_content?("Page Not Found")
  assert page.has_content?("Access Denied")
  assert page.has_content?("Server Error")
end