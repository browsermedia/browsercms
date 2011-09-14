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