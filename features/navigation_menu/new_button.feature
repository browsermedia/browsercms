Feature: New Button
  The 'New' button should make good guesses about what a user is most likely to want to add
  based on where they are currently.

  Background:
    Given I am logged in as a Content Editor

  Scenario: On a page
    When I am editing at page
    And I press the 'New' menu button
    Then it should add a page in the same section I as the page I was editing





