# Merge this into manage_content_block_steps after pulling this forward into 3.5.x

When /^I add content to the main area of the page$/ do
  click_on "add_new_content_main"
end

Given /^a product "([^"]*)" has been added to a page$/ do |name|
  @product = Product.create!(:name => name)
  page = FactoryGirl.create(:public_page)
  page.add_content(@product)
  page.publish!
end

When /^I view that product$/ do
  visit "/cms/products/#{@product.id}"
end

Given /^html with "([^"]*)" has been added to a page$/ do |body|
  @block = FactoryGirl.create(:html_block, :content => body)
  page = FactoryGirl.create(:public_page)
  page.add_content(@block)
  page.publish!
end

Given /^portlet named "([^"]*)" has been added to a page$/ do |name|
  @subject = FactoryGirl.create(:portlet, :name=>name)
  page = FactoryGirl.create(:public_page)
  page.add_content(@subject)
  page.publish!
end