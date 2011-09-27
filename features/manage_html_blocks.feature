Feature: Manage Html Blocks
  	As a content editor I should be able to add new HTML content to a site

  Background:
    Given the cms database is populated
    And I am logged in as a Content Editor

  Scenario: Adding a new Html Block
    Given I request /cms/html_blocks/new
    Then I should see a page titled "Add New Text"