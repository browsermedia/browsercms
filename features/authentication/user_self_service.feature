Feature:
  Users should be able to manage their own account profiles.

  Background:
    Given I have a content editor account
    And I am logged in
    And there is another user

  Scenario: Cannot edit other users
    When I try to edit another user account
    Then I should be denied access

  Scenario: Change my own password
    When I change my password
    Then I should be successful
    And I should be on the homepage

  Scenario: Change other users password
    When I try to change another user's password
    Then I should be denied access

  Scenario: Login into public site
    Given I am not logged in
    When I login to the public site
    Then I should be successful

  Scenario: Forgot Password
    Given I am not logged in
    When I go to the public login page
    Then there should be a forgot password link
    When I click the forgot password link
    And I enter my email address to reset my password
    Then I should receive an email with a reset password link.

  Scenario: Reset Password
    Given I am not logged in
    And I have requested to reset my password
    When I follow the link in the email
    And I enter my new password
    Then I should be able to log in with the new password