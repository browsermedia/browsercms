Feature: Caching
  In order for the site to scale there should be caching in place for pages.

  Background:
    Given I am logged in as a Content Editor
    
  Scenario: Clear Page Cache
    When I request /cms/cache
    Then I should see a page titled "Page Cache Info"
    When I click on "Clear Page Cache"
    Then I should see a page titled "Page Cache Info"

