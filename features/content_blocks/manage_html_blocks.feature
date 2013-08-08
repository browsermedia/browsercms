Feature: Manage Html Blocks
  As a content editor I should be able to add new HTML content to a site

  Background:
    Given I am logged in as a Content Editor

  Scenario: List Html Blocks
    Given the following Html blocks exist:
      | name      |
      | Hello CMS |
    Given I request /cms/html_blocks
    Then the response should be 200
    Then I should see a page titled "List Text"
    And I should see the following content:
      | Hello CMS     |

  Scenario: Save but not publish a New Block
    Given I request /cms/html_blocks/new
    Then I should see a page titled "Add New Text"
    When I fill in "Name" with "Hello World"
    And I click on "Save"
    Then I should see a page titled "Content Library / View Text"
    And I should see the following content:
      | draft                   |
      | View Text 'Hello World' |
    And the publish button should be enabled

  Scenario: Publishing a New Block
    Given I request /cms/html_blocks/new
    Then I should see a page titled "Add New Text"
    When I fill in "Name" with "Hello World"
    And I click on "Save And Publish"
    Then I should see a page titled "Content Library / View Text"
    And I should see the following content:
      | published               |
      | View Text 'Hello World' |
    And the publish button should be disabled

  Scenario: Publishing an existing block
    Given the following Html blocks exist:
      | id  | name  |
      | 100 | Hello |
    When I request /cms/html_blocks/100/edit
    When I fill in "Name" with "Hello World"
    And I click on "Save And Publish"
    Then I should see a page titled "Content Library / View Text"
    And I should see the following content:
      | published               |
      | View Text 'Hello World' |

  Scenario: View Usages
    Given html with "Hello World" has been added to a page
    When I view that block
    Then the response should be 200
    And the page header should be "View Text"
    And I should see "Used on: 1 page"

  Scenario: Multiple Pages
    Given there are multiple pages of html blocks in the Content Library
    When I request /cms/html_blocks
    Then I should see the paging controls
    And I click on "next_page_link"
    Then I should see the second page of content

  Scenario: Draft Html Block
    Given I have an Html block in draft mode
    When I view that block
    Then the publish button should be enabled
    And I should see that block's content
    And I should see it's draft mode
