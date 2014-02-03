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
  click_user_search
end

When /^I search for expired users$/ do
  visit "/cms/users"
  check 'show_expired'
  click_user_search
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
  click_user_search
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
  click_save_button
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
  visit cms.change_password_user_path(current_user)
  fill_in_password(acceptable_password)
  click_save_button
end

Then /^I should be successful$/ do
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

Given /^I create an expired user$/ do
  visit cms.new_user_path
  fill_in "Expiration Date", with: "2012/1/1"
  steps %Q{
    Then fill valid fields for a new user named "expired_dude"
  }
  @that_user = Cms::User.last
  assert_equal "expired_dude", @that_user.login
end

When /^fill valid fields for a new user named "([^"]*)"$/ do |username|
  fill_in "Username", :with => username
  fill_in "Email", :with => "#{username}@example.com"
  fill_in "First Name", :with => "Mr."
  fill_in "Last Name", :with => "Blank"
  fill_in_password(acceptable_password)
  click_save_button
end

Given /^the following content editor exists:$/ do |table|
  table.hashes.each do |row|
    row['login'] = row.delete('username')
    create(:content_editor, row)
  end
end

Given /^the following group exists:$/ do |table|
  table.hashes.each do |row|
    create(:cms_user_group, row)
  end
end

When /^I login as:$/ do |table|
  user = table.hashes.first
  login_as(user['login'], user['password'])
end
When /^I add a new user$/ do
  click_on "Add User"
end

When /^I look at expired users$/ do
  visit cms.users_path
  check "show_expired"
  click_user_search
end

When /^I login to the public site$/ do
  login_as(current_user.login, current_user.password, "/login")
end

When(/^I login in as an external user (?:again|for the first time)$/) do
  login_as_external_user
end

When /^it should create an external user record in the database$/ do
  should_be_exactly_one_external_user
end

Given(/^I have already logged in once as an external user$/) do
  login_as_external_user
end

Then(/^it should not create any new user records in the database$/) do
  should_be_exactly_one_external_user
end

Given(/^an external user exists$/) do
  login_as_external_user
end

When(/^I edit that external user$/) do
  visit cms.users_path
  click_on "Test User"
  should_be_successful
end

Then(/^I should be able to change some fields$/) do
  fill_in "First Name", with: "Tester"
  click_save_button
  should_be_successful
  should_see_a_page_titled "Users"
  assert page.has_content?("Tester User")
end

When /^I fill in passwords as "([^"]*)"$/ do |new_pw|
  fill_in_password(new_pw)
end

When /^I go to the public login page$/ do
  visit "/login"
end

Then /^there should be a forgot password link$/ do
  assert page.has_content?("Forgot your password?")
end

When /^I click the forgot password link$/ do
  click_on "Forgot your password?"
end

When /^I enter my email address to reset my password$/ do
  fill_in "Email", with: Cms::User.first.email
  click_on "Send me reset password instructions"
end

Then /^I should receive an email with a reset password link.$/ do
  should_be_successful
  assert_equal 1, ActionMailer::Base.deliveries.size
  assert_equal [Cms::User.first.email], ActionMailer::Base.deliveries.first.to
  assert page.has_content?("You will receive an email")
end

Given /^I have requested to reset my password$/ do
  visit forgot_password_path
  fill_in "Email", with: Cms::User.first.email
  click_on "Send me reset password instructions"
end

def cmsadmin
  Cms::User.first
end

When /^I follow the link in the email$/ do
  visit edit_password_path(reset_password_token: cmsadmin.reset_password_token, id: cmsadmin.id)
  should_see_a_page_titled "Reset Password"
end

When /^I enter my new password$/ do
  @new_password = "mynewpassword"
  fill_in "New password", with: @new_password
  fill_in "Confirm your new password", with: @new_password
  click_on "Change my password"
  should_be_successful
end

Then /^I should be able to log in with the new password$/ do
  login_as(Cms::User.first.login, @new_password)
  should_be_successful
end