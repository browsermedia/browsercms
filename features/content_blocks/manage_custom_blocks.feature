
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

  Scenario: Nonexistant Product
    Given no product with a slug "/some-path" exists
    And I am not logged in
    When I visit "/products/some-path"
    Then I should see the CMS 404 page








