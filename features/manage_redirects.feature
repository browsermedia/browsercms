Feature: Manage Redirects
  In order to avoid breaking links to old sites,
  admins should be able to create redirects between arbitrary paths in the CMS.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Create Redirect
    When I view the Redirects page
    Then I should see a page named "Redirects"
    When I click on "Add"
    Then I should see a page named "Add a New Redirect"
    When create a Redirect with the following:
      | from    | to      |
      | /path-a | /path-b |
    Then I should see a page named "Redirects"
    And I should see the following content:
      | /path-a |
      | /path-b |

  Scenario: Update Redirects
    Given the following redirects exist:
      | from      | to        |
      | /about-us | /about-you |
    When I edit the "/about-us" redirect
    And I fill in "To" with "/about-them"
    And I click the Save button
    Then I should see the following content:
    | /about-them |


