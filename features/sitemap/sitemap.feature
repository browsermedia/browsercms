Feature: Sitemap
  In order to see the structure of a site, and add new pages/sections, content editors should be able to see a sitemap
  showing content pages and sections.

  Background:
    Given I am logged in as a Content Editor

  Scenario: View as Admin
    Given there are some additional pages and sections
    When I request /cms/sitemap
    Then I should see a page named "Sitemap"
    And I should see the stock CMS pages
    And I should see the new pages and sections

  Scenario: Verify Editable Sections
    # Given there are some restricted sections and pages
    # Verify that I can edit some, but not others.
