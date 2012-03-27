Feature: Manage Content Blocks
  In BrowserCMS projects developers should be able to generate and manage content blocks via the UI.
  This blocks will be generated as Rails resources, with a controller and views.

  Background:
    Given a Content Type named "Product" is registered
    And I am logged in as a Content Editor

  Scenario: List Content Blocks
    When I request /cms/products
    Then I should see "List Products"

  Scenario: List Content Blocks
    When I request /cms/content_library
    Then I should see the following content:
      | Product       |
      | Text          |
      | File          |
      | Image         |
      | Portlet       |
      | Category      |
      | Category Type |
      | Tag           |

  Scenario: Create a new block
    When I request /cms/products/new
    Then I should see "Add New Product"
    When I fill in "Name" with "iPhone"
    And I fill in "Price" with "400"
    And I click on "Save"
    Then I should see "iPhone"
    Then I should see "400"

  Scenario: Delete a block
    Given the following products exist:
      | id | name        | price |
      | 1  | iPhone      | 400   |
      | 2  | Kindle Fire | 200   |
    When I delete "Kindle Fire"
    Then I should be redirected to /cms/products







