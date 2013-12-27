Feature: Caching
  In order for the site to scale there should be caching in place for pages.

  Background:
    Given I am logged in as a Content Editor
    
  Scenario: Clear Page Cache
    When I request /cms/cache
    Then I should see a page named "Page Cache"
    When I clear the page cache
    Then I should see a page named "Page Cache"

