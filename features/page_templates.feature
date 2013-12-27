Feature: Page Templates
  CMS Administrators should be able to create page and partial templates through the UI.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Add a Page Template
    When I am at /cms/page_templates
    And I click on "Add"
    Then I should see "New Page Template"
    When I fill in the following:
      | Name | hello |
      | Body | World |
    And I click the Save button
    Then I should see a page named "Page Templates"
    Then I should see the following content:
      | Hello |

  Scenario: Multiple pages of templates
    Given there are 20 page templates
    When I am at /cms/page_templates
    Then I should see "Displaying 1 - 15 of 20"
    When I click on "next_page_link"
    Then I should see "Displaying 16 - 20 of 20"

  Scenario: Edit a template
    Given the following page template exists:
      | name  |
      | hello |
    When I edit that page template
    Then the response should be 200
    And the page header should be "Edit 'hello' Page Template"
    When I fill in "Name" with "hello_world"
    And I click the Save button
    Then the response should be 200
    And the page header should be "Page Templates"
    And I should see the following content:
      | Hello World |


  Scenario: Delete a template
    Given the following page template exists:
      | name  |
      | hello |
    When I delete that page template
    Then the response should be 200
    And the page header should be "Page Templates"
    And I should not see the "Hello" template in the table

