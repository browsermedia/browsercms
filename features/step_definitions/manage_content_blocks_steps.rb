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
    Product.create!(:id=>row['id'], :name=>row['name'], :price=>row['price'])
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
