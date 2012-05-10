When /^the new group should have edit and publish permissions$/ do
  group = Cms::Group.last
  assert_equal 2, group.permissions.count
  assert group.has_permission?(:edit_content)
  assert group.has_permission?(:publish_content)
end

When /^the new group should have neither edit nor publish permissions$/ do
  group = Cms::Group.last
  assert_equal 0, group.permissions.count
  assert !group.has_permission?(:edit_content)
  assert !group.has_permission?(:publish_content)
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