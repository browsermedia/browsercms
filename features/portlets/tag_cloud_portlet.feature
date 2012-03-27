Feature: Tag Cloud Portlet
  Show a tag cloud

  Background:
    Given I am logged in as a Content Editor

  Scenario: Add New Portlet
    Given I visit /cms/portlets
    And the following tags exist:
    | name |
    | Red  |
    | Green |
    And the a block exist that are tagged with "Green"
    When I click on "add new content"
    And I click on "Tag Cloud Portlet"
    Then I should see a page titled "Add New Portlet"
    When I fill in "Name" with "My Cloud"
    And I click on "Save"
    Then I should not see "Red"
    And I should see the following content:
    | Green |






