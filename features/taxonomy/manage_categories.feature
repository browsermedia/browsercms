Feature: Manage Categories
  Content editors should be able to add/edit/delete categories from the user interface.

  Background:
    Given I am logged in as a Content Editor
    And the following Category Types exist:
      | name     |
      | Product |

  Scenario: Add New Category
    Given I visit /cms/categories/new
    And I fill in "Name" with "T-Shirts"
    And I select "Product" from "Type"
    And I click on "Save"
    Then I should see a page titled "List Categories"
    And I should see "T-Shirts"



