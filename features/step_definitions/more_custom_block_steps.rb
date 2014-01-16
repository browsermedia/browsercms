# Merge this into manage_content_block_steps after pulling this forward into 3.5.x

When /^I add content to the main area of the page$/ do
  visit
  click_on "add_new_content_main"
end

Given /^a product "([^"]*)" has been added to a page$/ do |name|
  @product = FactoryGirl.create(:product, :name => name)
  page = FactoryGirl.create(:public_page)
  page.add_content(@product)
  page.publish!
end

When /^I view that product$/ do
  visit cms_product_path(@product)
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

Given /^there is a page route for viewing a product$/ do
  page = FactoryGirl.create(:public_page, :name=>"View Product", :path=>"/products/view")
  route = page.page_routes.build(:name=>"Product", :pattern=>"/products/view/:id", :code=>"# Non-blank code")
  route.save!

  portlet_page = FactoryGirl.create(:public_page, :name=>"Product Catalog", :path=>"/products")
  portlet_page.add_content(ProductCatalogPortlet.create!(:name=>"Catalog"))
  portlet_page.publish!

  FactoryGirl.create(:product, name: "A Widget", slug: "/widget")
end

When /^I view a page that lists products$/ do
  visit "/products"
end

Then /^I should be able to click on a link to see a product$/ do
  assert page.has_content?("A Widget")
end
Then /^a new product should be created$/ do
  assert_equal 1, Dummy::Product.count
end

EXPECTED_PRODUCT_NAME = "About Us"

Given(/^a product with a slug "(.*?)" exists$/) do |slug|
  FactoryGirl.create(:product, name: EXPECTED_PRODUCT_NAME, slug: slug)
  assert_not_nil Dummy::Product.with_slug(slug)
end

Given /^no product with a slug "([^"]*)" exists$/ do |slug|
  assert_nil Dummy::Product.with_slug(slug)
end
When /^I view products in the content library$/ do
  visit dummy_products_path
end

Then /^I should see that product's page$/ do
  should_be_successful
  should_see_a_page_titled EXPECTED_PRODUCT_NAME
end

Given(/^a product exists with two versions$/) do
  @product = FactoryGirl.create(:product, name: "Version 1")
  @product.name = "Version 2"
  @product.save!
  assert_equal 2, @product.versions.size
end

Then(/^I should be able to see the version history for that product$/) do
  visit dummy_product_path(@product)
  click_on "Versions"
  should_see_a_page_titled "Versions: '#{@product.name}'"
end
