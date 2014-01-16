Feature: Manage Content Blocks
  In BrowserCMS projects developers should be able to generate and manage content blocks via the UI.
  This blocks will be generated as Rails resources, with a controller and views.

  Background:
    Given I am logged in as a Content Editor

  Scenario: List Content Blocks
    When I view products in the content library
    Then I should be returned to the Assets page for "Products"

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
    When I add a new product
    Then I should see a page named "Add a New Product"
    When I fill in "Name" with "iPhone"
    And I fill in "Slug" with "/iphone"
    And I click the Save button
    Then a new product should be created

  Scenario: Delete a block
    Given the following products exist:
      | id | name        | price |
      | 1  | iPhone      | 400   |
      | 2  | Kindle Fire | 200   |
    When I delete "Kindle Fire"
    Then I should be returned to the view products page in the content library

  Scenario: Multiple Pages
    Given there are multiple pages of products in the Content Library
    When I view products in the content library
    Then I should see the paging controls
    And I click on "next_page_link"
    Then I should see the second page of content

  Scenario: Custom Page Routes
    Given there is a page route for viewing a product
    And I am a guest
    When I view a page that lists products
    Then I should be able to click on a link to see a product

  Scenario: View Product Page
    Given I am a guest
    And a product with a slug "about-us" exists
    When I visit "/products/about-us"
    Then I should see that product's page

  Scenario: Nonexistant Product
    Given no product with a slug "some-path" exists
    And I am not logged in
    When I visit "/products/some-path"
    Then I should see the CMS 404 page

  Scenario: Looking at older versions
    Given a product exists with two versions
    Then I should be able to see the version history for that product





