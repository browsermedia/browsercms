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

  Scenario: Add to a page
    When I visit /
    And I turn on edit mode for /
    And I add content to the main area of the page
    And I click on "Product"
    And I fill in "Name" with "iPhone"
    And I click on "Save"
    Then the response should be 200
    And I should see "Name: iPhone"

  Scenario: View Usages
    Given a product "iPhone" has been added to a page
    When I view that product
    Then the response should be 200
    And the page header should be "View Product 'iPhone'"
    And I should see "Used on: 1 page"

  Scenario: Multiple Pages
    Given there are multiple pages of products in the Content Library
    When I request /cms/products
    Then I should see the paging controls
    And I click on "next_page_link"
    Then I should see the second page of content

  Scenario: Custom Page Routes
    Given there is a page route for viewing a product
    And I am a guest
    When I view a page that lists products
    Then I should be able to click on a link to see a product










