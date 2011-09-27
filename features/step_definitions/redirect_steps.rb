When /^I view the Redirects page$/ do
  visit "/cms/administration"
  click_on "Redirects"
end

When /^create a Redirect with the following:$/ do |table|
  redirect = table.hashes.first
  fill_in "From", :with=>redirect['from']
  fill_in "To", :with=>redirect['to']
  click_on 'Save'
end

