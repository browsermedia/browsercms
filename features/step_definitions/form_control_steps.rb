Then /^I should see a label named "([^"]*)"$/ do |label_name|
  assert page.has_css? "label", text: label_name
end

When /^I should see a file upload button$/ do
  assert page.has_css? "input[type=file]"
end

When /^I should see the following instructions:$/ do |table|
  table.rows.each do |text|
    assert page.has_css? ".instructions", text: text
  end
end