When /^a Content Type named "Product" is registered$/ do
  p = "Product"
  Cms::ContentType.create!(:name => p, :group_name => p)
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