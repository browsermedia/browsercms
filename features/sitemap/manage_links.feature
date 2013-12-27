Feature: Manage Links
  Content Editors should be able to create links on the sitemap in order to have menu items that go to URLs that are
  served by CMS pages.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Add Link
    When I am adding a link on the sitemap
    And I fill in "Name" with "A New Link"
    And I fill in "Url" with "http://www.browsercms.com"
    And I click the Save button
    Then I should see a page named "Sitemap"
    Then I should see the following content:
      | A New Link |


  Scenario: Update And Publish Link
    Given the following link exists:
      | name | url                | section |
      | CMS  | www.browsercms.com | /       |
    When I edit that link
    And I change the link name to "A more well tested CMS"
    Then I should see a page named "Sitemap"
    Then I should see the following content:
      | A more well tested CMS |


