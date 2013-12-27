When /^I view the Redirects page$/ do
  visit "/cms/administration"
  click_on "Redirects"
end

When /^create a Redirect with the following:$/ do |table|
  redirect = table.hashes.first
  fill_in "From", :with=>redirect['from']
  fill_in "To", :with=>redirect['to']
  click_save_button
end

Given /^the following redirects exist:$/ do |table|
  table.hashes.each do |row|
    Cms::Redirect.create!(:from_path=>row[:from], :to_path=>row[:to])
  end
end

When /^I edit the "([^"]*)" redirect$/ do |from_path|
  r = Cms::Redirect.from(from_path)
  visit "/cms/redirects/#{r.id}/edit"
end