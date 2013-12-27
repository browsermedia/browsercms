Feature:  Pages
  Content Editors should be able to manage pages from the sitemap.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Create Page
    Given I am adding a page to the root section
    And I fill in "page_name" with "A New Page"
    And I fill in "Path" with "/my-new-page"
    And I select "Default" from "Template"
    And I click the Save button
    Then I should see a page titled "A New Page"

  Scenario: Edit a Page
    Given that a page I want to edit exists
    When I go to the sitemap
    And I select the page to edit
    And I change the page name
    Then I should be returned to that page
    And I should see the new page name
