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
    Then I should be returned to the Assets page for "Text"
    And I should see the following content:
      | Hello CMS     |

  Scenario: Save but not publish a New Block
    Given I request /cms/html_blocks/new
    Then I should see a page named "Add a New Text"
    When I fill in "Name" with "Hello World"
    And I click the Save button
    Then I should see the View Text page
    And I should see it's draft mode

  Scenario: Publishing a New Block
    Given I request /cms/html_blocks/new
    Then I should see a page named "Add a New Text"
    When I fill in "Name" with "Hello World"
    And I Save And Publish
    Then I should see the View Text page
    And the content should be published

  Scenario: Publishing an existing block
    Given the following Html blocks exist:
      | id  | name  |
      | 100 | Hello |
    When I request /cms/html_blocks/100/edit
    When I fill in "Name" with "Hello World"
    And I Save And Publish
    Then I should see the View Text page
    And the content should be published

  Scenario: Multiple Pages
    Given there are multiple pages of html blocks in the Content Library
    When I request /cms/html_blocks
    Then I should see the paging controls
    And I click on "next_page_link"
    Then I should see the second page of content

  Scenario: Draft Html Block
    Given I have an Html block in draft mode
    When I view that block
    And I should see that block's content
    And I should see it's draft mode
