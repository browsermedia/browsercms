Feature: Add Content with categories

  Background:
    Given I am logged in as a Content Editor

  Scenario: With no Category Type defined yet
    When I add a new product
    Then I should see "You must first create a 'Category Type' named 'Product'"

  Scenario: With No Categories
    Given the following Category Types exist:
      | name    |
      | Product |
    When I add a new product
    Then I should see "You must first create a Category with a Category Type of 'Product'."

  Scenario: With Categories
    Given the following Category Types exist:
      | name    |
      | Product |
    And the following Categories exist for "Product":
      | name     |
      | T-shirts |
      | Hoodies  |
    When I add a new product
    Then I should see the following content:
      | T-shirts |
      | Hoodies  |
