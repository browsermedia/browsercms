Feature: Manage Pages
  As a content editor I should be able to create pages

  Background:
    Given I am logged in as a Content Editor

  Scenario: Edit Page
    When I create a new page
    Then I should the content rendered inside the editor frame

  Scenario: Creating Page as unpublished
    When I create a new page
    Then that page should not be published

  Scenario: Publishing a Page (which was unpublished)
    When I create a new page
    Then I publish that page
    And that page should be published
    And I should end up on that page
