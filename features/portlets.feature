Feature: Portlets
  In order to support dynamic content on my site
  As a content editor
  I want to be able to dynamically display content.

  Background: A Homepage
    Given the cms database is populated

  Scenario: When logged in
    Given I am logged in as a Content Editor
    And there is a LoginPortlet on the homepage
    And I am on the homepage
    Then I should see Welcome, cmsadmin

  Scenario: When logged out
    Given there is a LoginPortlet on the homepage
    And I am on the homepage
    Then I should see the following content:
      | Login       |
      | Password    |
      | Remember me |

  Scenario: Viewing a portlet
    Given I am logged in as a Content Editor
    And there is a "Portlet" with:
      | name          | template    |
      | A new portlet | Hello World |
    When I go to the content library
    And follow "Portlet"
    Then I should see the following content:
      | A new portlet |

  # Portlets aren't deleting or updating due to errors with dynamic attributes.
  Scenario: Deleting a portlet
    Given I am logged in as a Content Editor
    And there is a "Portlet" with:
      | name          | template    |
      | A new portlet | Hello World |
    When I delete that portlet
    And I go to the content library
    And I click on "Portlet"
    And I should not see "A new portlet"
    When I view that portlet
    Then the response should be 500

  # Portlets aren't deleting or updating due to errors with dynamic attributes.
  Scenario: Editing a portlet
    Given I am logged in as a Content Editor
    And there is a "Portlet" with:
      | name          | template    |
      | A new portlet | Hello World |
    When I edit that portlet
    And fill in "Name" with "New Name"
    And fill in "Template" with "New World"
    And I click on "Save"
    Then I should see the following content:
      | View Portlet 'New Name' |
      | New World               |
    And I should not see the following content:
    | A new portlet |
    | Hello World   |
