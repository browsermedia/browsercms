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
