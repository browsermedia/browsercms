Feature: Email a Friend Portlet
  Allows users to email a page to a friend by clicking on a link and filling out a form. An email will be generated with
  a link to whatever page the portlet is embedded into.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Add New Portlet
    Given I visit /cms/portlets
    When I click on "add new content"
    And I click on "Email Page Portlet"
    Then I should see a page titled "Add New Portlet"
    When I fill in "Name" with "Hello"
    And I click on "Save"
    Then I should not see "ERROR"
    Then I should see the following content:
    | Recipients |
    | Body       |
    When I fill in "Recipients" with "test@example.com"
    And I fill in "Body" with "Testing"
    And I press "Send Email"
    Then I should not see the following content:
    | error |





