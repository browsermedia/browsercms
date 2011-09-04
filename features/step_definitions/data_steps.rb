Then /^I should see the following content:$/ do |table|
  table.raw.each do |row|
    assert page.has_content?(row[0]), "Couldn't find #{row[0]}' anywhere on the page."
  end
end