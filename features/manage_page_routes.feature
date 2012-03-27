Feature: Manage Page Routes
  Admins should be able to see existing Rails routes, as well as add new 'dynamic' routes via the Admin.
  These routes will be used to handle custom portlet pages (like viewing a single 'News' article) using a
  nicely formatted path.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Show Rails Routes
    When I request /cms/routes
    Then I should see a page titled "Rails Routes"

  Scenario: Match a path to a Controller
    When I request /cms/routes
    And I search for a path including "/cms/sample_blocks/1"
    Then I should see the following content:
      | {:action=>"show", :controller=>"cms/sample_blocks", :id=>"1"} |

  Scenario: Create Page Route
    When I request /cms/page_routes
    Then I should see a page titled "List Page Routes"
    When I click on "Add"
    Then I should see a page titled "New Page Route"
    When create a Page Route with the following:
      | name     |
      | my_route |
    Then I should see a page titled "'my_route' Page Route"
    And I should see the following content:
      | my_route |

  Scenario: Edit Page Route
    Given a Page Route exists
    When I edit that page route
    Then I should see a page titled "Edit Page Route"
    When I fill in "Name" with "My Updated Route"
    And I click on "Save"
    Then I should see a page titled "'My Updated Route' Page Route"
    And I should see "My Updated Route"

  Scenario: A simple route to a CMS page
    Given a public page exists
    When there is a portlet that displays ":name" from the route
    When a page route with the pattern "/hello/:name" exists
    When I request /hello/World
    Then I should see "World"


  Scenario: Calling a route with valid segment constraints
    Given there is a dynamic page that looks up content by date
    And a page route with following exists:
      | pattern        |
      | /content/:year |
    When I request /content/2011
    Then I should see content for that year only

  Scenario: Calling a route with invalid segment constraints
    Given there is a dynamic page that looks up content by date
    And a page route with following exists:
      | pattern        | constraint |
      | /content/:year | d{4}       |
    When I request /content/20
    Then I should see the CMS 404 page

  Scenario: Calling a route with invalid method
    Given there is a dynamic page that looks up content by date
    And a page route with following exists:
      | pattern        | method |
      | /content/:year | GET    |
    When I POST to /content/2011
    Then I should see the CMS 404 page

