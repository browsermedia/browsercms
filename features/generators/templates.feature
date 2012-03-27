@cli
Feature:
  Developers working in BrowserCMS projects should be able to generate templates.

  Background:
    Given a BrowserCMS project named "petstore" exists
    And I cd into the project "petstore"

  Scenario: Generate Template
    When I run `rails g cms:template subpage`
    And a file named "app/views/layouts/templates/subpage.html.erb" should exist

  Scenario: Generate Mobile template
    When I run `rails g cms:template subpage --mobile`
    And a file named "app/views/layouts/mobile/subpage.html.erb" should exist
