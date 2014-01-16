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

