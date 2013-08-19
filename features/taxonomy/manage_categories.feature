Feature: Manage Categories
  Content editors should be able to add/edit/delete categories from the user interface.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Add New Category
    Given the following Category Types exist:
      | name    |
      | Product |
    And I add a new category
    When I fill in "Name" with "T-Shirts"
    And I select "Product" from "Type"
    And I click on "Save"
    Then I should see a page named "List Categories"
    And I should see "T-Shirts"

  Scenario: Add Category with no category types
    When no category types exist
    And I add a new category
    Then I should see "create a category type"




