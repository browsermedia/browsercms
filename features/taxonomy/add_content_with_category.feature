Feature: Add Content with categories

  Background:
    Given a Content Type named "Product" is registered
    And I am logged in as a Content Editor

  Scenario: With no Category Type defined yet
    When I visit /cms/products/new
    Then I should see "You must first create a 'Category Type' named 'Product'"

  Scenario: With No Categories
    Given the following Category Types exist:
      | name    |
      | Product |
    When I request /cms/products/new
    Then I should see "You must first create a Category with a Category Type of 'Product'."

  Scenario: With Categories
    Given the following Category Types exist:
      | name    |
      | Product |
    And the following Categories exist for "Product":
      | name     |
      | T-shirts |
      | Hoodies  |
    When I visit /cms/products/new
    Then I should see the following content:
      | T-shirts |
      | Hoodies  |
