Feature: Manage Sections
  Content Editors should be able to create sections from the sitemap in order to organize site content.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Create Section
    Given I am adding a section to the root section
    When I create a public section
    Then I should see a page named "Sitemap"
    And the new section should be accessible to everyone