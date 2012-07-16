Feature: Portlet Helpers
  Portlets should automatically include their helpers as part of their view.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Render Portlet Helpers
    Given there is a portlet that uses a helper
    When I view that page
    Then I should see the portlet helper rendered in the view