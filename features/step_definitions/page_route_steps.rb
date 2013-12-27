When /^create a Page Route with the following:$/ do |table|
  redirect = table.hashes.first
  select "/ (Home)", :from=>"Page"
  fill_in "Name", :with=>redirect['name']
  fill_in "Pattern", :with=>"/any/pattern"
  click_save_button
end

Given /^a Page Route exists$/ do
  @last_route = create(:page_route)
end
When /^I edit that page route$/ do
  visit "/cms/page_routes/#{@last_route.id}/edit"
end

Given /^a public page exists$/ do
  @last_page = create(:public_page)
end

When /^there is a portlet that displays ":name" from the route$/ do
  @portlet = create(:portlet, :template=>"Hello <%= @name %>")
  @last_page.add_content(@portlet)
  @last_page.publish!
end

When /^a page route with the pattern "([^"]*)" exists$/ do |pattern|
  @route = create(:page_route, :pattern=>pattern, :page=>@last_page, :code=>"@name = params[:name]")
end

Given /^there is a dynamic page that looks up content by date$/ do
  @last_page = create(:public_page)

  template = <<ERB
  <%= @result %>
ERB
  @portlet = create(:portlet, :template=>template)
  @last_page.add_content(@portlet)
  @last_page.publish!
end


When /^a page route with following exists:$/ do |table|
  data = table.hashes.first
  code = <<RUBY
if params[:year] == "2011"
  @result = "I worked"
else
  @result = "I didn't work"
end
RUBY
  @route = create(:page_route, :pattern=> data['pattern'], :code => code, :page=>@last_page)
  @route.add_constraint(:year, data['constraint']) if data['constraint']
  @route.via = data['method'] if data['method']
  @route.save!
end
Then /^I should see content for that year only$/ do
  assert page.has_content?("I worked")
end

When /^I POST to (.+)$/ do |path|
  page.driver.post(path)
end
When /^I search for a path including "([^"]*)"$/ do |pattern|
  visit "/cms/routes?path=#{pattern}"
end