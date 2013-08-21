Feature: Portlets
  In order to support dynamic content on my site
  As a content editor
  I want to be able to dynamically display content.

  Background:
    Given I am logged in as a Content Editor

  Scenario: List Portlets
    When I visit /cms/portlets
    Then I should see a page titled "List Portlets"

  Scenario: Login portlet when logged in
    And there is a LoginPortlet on the homepage
    And I am editing the page at /
    Then the page content should contain "Welcome, cmsadmin"

  Scenario: Login portlet when logged out
    Given there is a LoginPortlet on the homepage
    And I am not logged in
    And I am on the homepage
    Then I should see the following content:
      | Login       |
      | Password    |
      | Remember me |

  Scenario: Viewing a portlet
    Given there is a "Portlet" with:
      | name          | template    |
      | A new portlet | Hello World |
    When I request /cms/content_library
    And follow "Portlet"
    Then I should see the following content:
      | A new portlet |
    When I view that portlet
    Then I should see the following content:
     | A new portlet |

  Scenario: Deleting a portlet
    Given there is a "Portlet" with:
      | name          | template    |
      | A new portlet | Hello World |
    When I delete that portlet
    And I request /cms/content_library
    And I click on "Portlet"
    And I should not see "A new portlet"
    When I view that portlet
    Then I should see the following content:
      | has been deleted |

  Scenario: Editing a portlet
    Given there is a "Portlet" with:
      | name          | template    |
      | A new portlet | Hello World |
    When I edit that portlet
    And fill in "Name" with "New Name"
    And fill in "Template" with "New World"
    And I click on "Save"
    Then I should see the following content:
      | View Portlet 'New Name' |
      | New World               |
    And I should not see the following content:
      | A new portlet |
      | Hello World   |

  Scenario: Page with portlet on it
    Given I am not logged in
    And a page with a portlet that display "Hello World" exists
    When I visit that page
    Then I should see the following content:
      | Hello World |

  Scenario: Portlet throws a 404 Error
    Given I am not logged in
    And a page with a portlet that raises a Not Found exception exists
    When I visit that page
    Then I should see the CMS 404 page

  Scenario: Portlet throws an 403 Error
    Given I am not logged in
    And a page with a portlet that raises an Access Denied exception exists
    When I visit that page
    Then I should see the CMS :forbidden page

  Scenario: Portlet throws 404 and 403 errors
    Given I am not logged in
    And a page with a portlet that raises both a 404 and 403 error exists
    When I visit that page
    Then I should see the CMS 404 page

  Scenario: Portlet throws 403 and any other error
    Given I am not logged in
    And a page with a portlet that raises both a 403 and any other error exists
    When I visit that page
    Then I should see the CMS :forbidden page

  # @todo - Actual broken feature. Need to fix implementation
  Scenario: Portlet errors should not blow up the page
    Given a bug: Portlet errors should not throw 500 and blow up the page.
    Given I am not logged in
    And a portlet that throws an unexpected error exists
    When I view that page
    Then the page should show content but not the error

  Scenario: View Usages
    Given portlet named "Hello World" has been added to a page
    When I view that portlet
    Then the response should be 200
    And the page header should be "View Portlet 'Hello World'"
    And I should see "Used on: 1 page"

  Scenario: Multiple Pages
    Given there are multiple pages of portlets in the Content Library
    When I request /cms/portlets
    Then I should see the paging controls
    And I click on "next_page_link"
    Then I should see the second page of content

  Scenario: Portlets can override page titles
    Given a developer creates a portlet which sets a custom page title as "A Custom Title"
    When a guest views that page
    Then I should see a page titled "A Custom Title"