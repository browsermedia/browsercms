Given /^the following Category Types exist:$/ do |table|
  table.hashes.each do |attributes|
    FactoryGirl.create(:category_type, attributes)
  end
end

When /^the following Categories exist for "([^"]*)":$/ do |category_type, table|
  type = Cms::CategoryType.named(category_type).first
  table.hashes.each do |attributes|
    attributes.merge!({:category_type_id => type.id })
    FactoryGirl.create(:category, attributes)
  end
end
Then /^an image with id "([^"]*)" should exist$/ do |arg|
  assert Cms::ImageBlock.find(arg.to_i)
end