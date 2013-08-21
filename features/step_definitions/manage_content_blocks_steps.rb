module CustomBlockHelpers

  def register_content_type(type)
    Cms::ContentType.create!(:name => type, :group_name => type)
  end
end

World(CustomBlockHelpers)

When /^a Content Type named "Product" is registered$/ do
  register_content_type("Product")
end

Given /^the following products exist:$/ do |table|
  # table is a | 1  | iPhone      | 400   |
  table.hashes.each do |row|
    Product.create!(:id => row['id'], :name => row['name'], :price => row['price'])
  end
end
When /^I delete "([^"]*)"$/ do |product_name|
  p = Product.find_by_name(product_name)
  page.driver.delete "/cms/products/#{p.id}"
end
Then /^I should be redirected to ([^"]*)$/ do |path|
  assert_equal "http://www.example.com#{path}", page.response_headers["Location"]
end

Then /^"([^"]*)" should be selected as the current Content Type$/ do |name|
  select = name.tableize.singularize
  if name == "Text"
    select = "html_block"
  end
  li = find(:xpath, "//li[@rel='select-#{select}']")
  assert li['class'].include?("on")
end

When /^I Save And Publish$/ do
  click_button "Save And Publish"
end

Given /^there are multiple pages of portlets in the Content Library$/ do
  per_page = Cms::Behaviors::Pagination::DEFAULT_PER_PAGE
  (per_page * 2).times do
    create(:portlet)
  end
end

Given /^there are multiple pages of html blocks in the Content Library$/ do
  per_page = Cms::Behaviors::Pagination::DEFAULT_PER_PAGE
  two_pages_of_blocks = (per_page * 2) - Cms::HtmlBlock.count
  two_pages_of_blocks.times do
    create(:html_block)
  end
end

Given /^there are multiple pages of products in the Content Library$/ do
  per_page = Cms::Behaviors::Pagination::DEFAULT_PER_PAGE
  (per_page * 2).times do |i|
    Product.create(:name => "Product #{i}")
  end
end

Then /^I should see the paging controls$/ do
  assert_equal 200, page.status_code
  assert page.has_content?("Displaying 1 - 15 of 30")
end

Then /^I should see the second page of content$/ do
  assert_equal 200, page.status_code
  assert page.has_content?("Displaying 16 - 30 of 30")
end

When /^I create a new "([^"]*)" portlet$/ do |portlet_type|
  click_on 'create_new_portlet'
  click_on portlet_type
end

When /^the publish button should be (#{ENABLED_OR_DISABLED})$/ do |is_enabled|
  button = find('#publish_button')
  assert_equal !is_enabled, button[:class].include?('disabled')
end

Given /^I have an Html block in draft mode$/ do
  @block = create(:html_block, :content=>"Testing Modes")
  @block.update_attributes(:name => "Should be updated.", :publish_on_save => false)
  refute @block.live?, "Assumed: Block should not be published."
end

When /^I should see that block's content$/ do
  assert page.has_content?(@block.content), "Expected to see #{@block.content} on the page."
end

When /^I should see it's draft mode$/ do
  within("#page-status-label") do
    assert page.has_content?('DRAFT')
  end
end