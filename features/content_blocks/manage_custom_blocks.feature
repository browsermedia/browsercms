
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
    And I fill in "product_slug" with "/iphone"
    And I click on "Save"
    Then a new product should be created

  Scenario: Delete a block
    Given the following products exist:
      | id | name        | price |
      | 1  | iPhone      | 400   |
      | 2  | Kindle Fire | 200   |
    When I delete "Kindle Fire"
    Then I should be redirected to /cms/products

  Scenario: Add to a page
    When I am editing the page at /
    And I add content to the main area of the page
    And I click on "add_new_product"
    And I fill in "Name" with "iPhone"
    And I click on "Save"
    Then the response should be 200
    Then the page content should contain "Name: iPhone"

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










