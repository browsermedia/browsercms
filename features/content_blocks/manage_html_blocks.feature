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
    Then "Text" should be selected as the current Content Type
    And I should see the following content:
      | Hello CMS     |
      | Include body? |

  Scenario: Publishing a New Block
    Given I request /cms/html_blocks/new
    Then I should see a page titled "Add New Text"
    When I fill in "Name" with "Hello World"
    And I click on "Save And Publish"
    Then I should see a page titled "Content Library / View Text"
    And I should see the following content:
      | published               |
      | View Text 'Hello World' |

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

    
  