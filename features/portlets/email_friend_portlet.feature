Feature: Email a Friend Portlet
  Allows users to email a page to a friend by clicking on a link and filling out a form. An email will be generated with
  a link to whatever page the portlet is embedded into.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Add New Portlet
    Given I visit /cms/portlets
    When I create a new "Email Page Portlet" portlet
    Then I should see a page named "Add a New Portlet"
    When I fill in "Name" with "Hello"
    And I fill in "Sender" with "hello@browsercms.org"
    And I click the Save button
    Then I should not see "ERROR"
    Then I should see the following content:
    | Recipients |
    | Body       |
    When I fill in "Recipients" with "test@example.com"
    And I fill in "Body" with "Testing"
    And I press "Send Email"
    Then I should not see the following content:
    | error |





