Feature: Manage Redirects
  In order to avoid breaking links to old sites,
  admins should be able to create redirects between arbitrary paths in the CMS.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Create Redirect
    When I view the Redirects page
    Then I should see a page titled "List Redirects"
    When I click on "Add"
    Then I should see a page titled "New Redirect"
    When create a Redirect with the following:
      | from    | to      |
      | /path-a | /path-b |
    Then I should see a page titled "List Redirects"
    And I should see the following content:
    | /path-a |
    | /path-b |
