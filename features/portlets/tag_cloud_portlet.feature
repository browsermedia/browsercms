Feature: Tag Cloud Portlet
  Show a tag cloud

  Background:
    Given I am logged in as a Content Editor

  Scenario: Add New Portlet
    Given I visit /cms/portlets
    And the following tags exist:
    | name |
    | AnNonexistantColor  |
    | Green |
    And the a block exist that are tagged with "Green"
    When I create a new "Tag Cloud Portlet" portlet
    Then I should see a page named "Add New Portlet"
    When I fill in "Name" with "My Cloud"
    And I click on "Save"
    Then I should not see "AnNonexistantColor"
    And I should see the following content:
    | Green |






