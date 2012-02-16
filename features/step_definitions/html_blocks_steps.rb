# i.e.  | id | name |
#       | 1  |  A   |
Given /^the following Html blocks exist:$/ do |table|
  table.hashes.each do |row|
    b = Cms::HtmlBlock.new(row)
    b.id = row['id']
    b.save!
  end
end
