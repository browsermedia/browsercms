Given /^I view the list of users$/ do
  visit '/cms/users'
end

Then /^I should see myself on the list$/ do
  @user = Cms::User.first
  assert page.has_content?(@user.email)
end

Given /^the following user exists:$/ do |table|
  table.hashes.each do |row|
    group_name = row.delete('group')

    @that_user = create(:user, row)
    if group_name
      group = create(:group, name: group_name)
      @that_user.groups << group
    end

  end
end

Given /^the following disabled user exists:$/ do |table|
  @that_user = create(:disabled_user, from_first_row(table))
end

When /^I search for a user with "([^"]*)"$/ do |search_term|
  visit "/cms/users"
  fill_in "key_word", with: search_term
  click_on 'user_search_submit'
end

When /^I search for expired users$/ do
  visit "/cms/users"
  check 'show_expired'
  click_on 'user_search_submit'
end

When /^there exists some other users$/ do
  create(:user, email: "dont-find@example.com")
end

Then /^I should see only that user$/ do
  should_be_successful
  assert page.has_css?("a", text: @that_user.email)
  assert !page.has_css?("a", text: "dont-find@example.com")
end
When /^I search for users with group "([^"]*)"$/ do |group_name|
  visit "/cms/users"
  select group_name, from: 'group_id'
  click_on 'user_search_submit'
end

Then /^I should not see that user$/ do
  should_be_successful
  assert !page.has_css?("a", text: @that_user.email)
end

Then /^I should see that user$/ do
  should_be_successful
  assert page.has_css?("a", text: @that_user.email)
end
When /^I add that user to a new group$/ do
  create(:group, name: "Sample Group")

  visit "/cms/users/#{@that_user.id}/edit"
  check "Sample Group"
  click_on "Save"
end

Then /^that user should have (\d+) group$/ do |number|
  assert_equal number.to_i, @that_user.groups.size
end

When /^I try to edit another user account$/ do
  visit cms.edit_user_path(@another_user)
end

Then /^I should be denied access$/ do
  assert_equal 403, page.status_code
end

Given /^I have a content editor account$/ do
  self.current_user = create(:content_editor)
end

When /^I am logged in$/ do
  login_as(current_user.login, current_user.password)
end

When /^there is another user$/ do
  @another_user = create(:registered_user)
end

When /^I change my password$/ do
  visit "/cms/users/#{current_user.id}/change_password"
  fill_in "Password", with: "new"
  fill_in "Confirm Password", with: "new"
  click_on "Save"
end

Then /^I should successful$/ do
  should_be_successful
end

When /^I try to change another user's password$/ do
  visit cms.change_password_user_path(@another_user)
end
When /^no category types exist$/ do
  Cms::CategoryType.delete_all
end
When /^I add a new category$/ do
  visit '/cms/categories/new'
end