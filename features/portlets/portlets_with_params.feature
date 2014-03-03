Feature: Portlets with Parameters
  Portlets should be able to read request parameters and display content accordingly.

  Background:
    Given there is a portlet that finds content by parameter

  # Finding content by id should be less necessary now that the Addressable Content feature is available.
  # However, this feature is still available and backwards compatible.
  Scenario: Find Content by parameter
    Given I am not logged in
    When I view that Find Content Portlet
    Then I should see the content loaded by that Portlet

  Scenario: Find Content by parameter
    Given I am logged in as a Content Editor
    And I view that Find Content Portlet in the page editor
    Then I should see the content loaded by that Portlet




