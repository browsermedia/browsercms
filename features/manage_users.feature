Feature: Manage Users
  CMS Admins should be able to add/edit/disable users via the Admin UI.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Add User
    Given I request /cms/users
    And I click on "ADD USER"
    Then I should see a page titled "New User"
    When fill valid fields for a new user named "testuser"
    Then I should see a page titled "User Browser"
    And I should see the following content:
      | testuser |

  Scenario: Change Password
    Given the following content editor exists:
      | username | password | first_name | last_name |
      | testuser | abc123   | Mr         | Blank     |
    When I request /cms/users
    And I click on "Mr Blank"
    And I click on "Change Password"
    And I fill in "Password" with "different"
    And I fill in "Confirm Password" with "different"
    And I press "Save"
    Then I should see a page titled "User Browser"
    When I login as:
      | login    | password  |
      | testuser | different |
    Then I should see a page titled "Home"

  Scenario: Multiple Pages of Users
    Given there are 20 users
    When I am at /cms/users
    Then I should see "Displaying 1 - 10 of 20"
    When I click on "next_page_link"
    Then I should see "Displaying 11 - 20 of 20"






