Given /^there are (\d+) page templates$/ do |count|
  count.to_i.times do |i|
    Factory(:page_template)
  end
end
