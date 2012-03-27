Feature: Create Pages
  Content Editors should be able to create pages from the sitemap in order to show content to their users.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Create Page
    Given I am adding a page to the root section
    And I fill in "Name" with "A New Page"
    And I fill in "Path" with "/my-new-page"
    And I select "Default" from "Template"
    And I click on "Save"
    Then I should see a page titled "A New Page"
    