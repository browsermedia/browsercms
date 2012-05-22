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

Given /^there is a page route for viewing a product$/ do
  page = FactoryGirl.create(:public_page, :name=>"View Product", :path=>"/products/view")
  route = page.page_routes.build(:name=>"Product", :pattern=>"/products/view/:id", :code=>"# Non-blank code")
  route.save!

  portlet_page = FactoryGirl.create(:public_page, :name=>"Product Catalog", :path=>"/products/list")
  portlet_page.add_content(ProductCatalogPortlet.create!(:name=>"Catalog"))
  portlet_page.publish!

  product = Product.create!(:name => "A Widget", :publish_on_save=>true)

end

When /^I view a page that lists products$/ do
  visit "/products/list"
end

Then /^I should be able to click on a link to see a product$/ do
  assert page.has_content?("A Widget")
end