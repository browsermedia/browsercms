Feature:
  Users should be able to manage their own account profiles.

  Background:
    Given I have a content editor account
    And I am logged in
    And there is another user

  Scenario: Cannot edit other users
    When I try to edit another user account
    Then I should be denied access

  @known-bug
  Scenario: Change my own password
    When I change my password
    Then I should successful

  Scenario: Change other users password
    When I try to change another user's password
    Then I should be denied access




