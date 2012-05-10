Given /^there are (\d+) page routes$/ do |i|
  i.to_i.times do
    create(:page_route)
  end
end

Given /^there are (\d+) groups$/ do |i|
  total = i.to_i - Cms::Group.count
  total.times do
    create(:cms_user_group)
  end
end

Given /^there are (\d+) users$/ do |i|
  total = i.to_i - Cms::User.count
  total.times do
    create(:user)
  end
end

Given /^there are (\d+) send email messages$/ do |i|
  i.to_i.times do
    Cms::EmailMessage.create!(:recipients => "example@browsermedia.com")
  end
end