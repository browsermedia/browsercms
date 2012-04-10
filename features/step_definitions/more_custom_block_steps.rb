# Merge this into manage_content_block_steps after pulling this forward into 3.5.x

When /^I add content to the main area of the page$/ do
  click_on "add_new_content_main"
end

Given /^a product "([^"]*)" has been added to a page$/ do |name|
  @product = Product.create!(:name => name)
  page = Factory(:public_page)
  page.add_content(@product)
  page.publish!
end

When /^I view that product$/ do
  visit "/cms/products/#{@product.id}"
end

Given /^html with "([^"]*)" has been added to a page$/ do |body|
  @block = Factory(:html_block, :content => body)
  page = Factory(:public_page)
  page.add_content(@block)
  page.publish!
end

When /^I view that block/ do
  visit "/cms/html_blocks/#{@block.id}"
end

Given /^portlet named "([^"]*)" has been added to a page$/ do |name|
  @subject = Factory(:portlet, :name=>name)
  page = Factory(:public_page)
  page.add_content(@subject)
  page.publish!
end