Feature: Tags
  Content editors should be able to add/edit/delete tags from the user interface.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Add New Tag
    Given I am adding a new tag
    When I fill in "Name" with "red"
    And I click the Save button
    Then I should be returned to the Assets page for "Tags"
    And I should see "red"



