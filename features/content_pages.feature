Feature: Content Pages
  Visitors should be able to see content pages

# This should be ported from test/functional/content_controller_test.rb over time.

  Background:
    Given I am a guest

  Scenario: Page Not Found as Guest
    Given I request /a/non-existent/page
    Then I should see the CMS 404 page

  Scenario: Viewing an archived page as a Guest
    Given an archived page at "/an/archived-page" exists
    When I request /an/archived-page
    Then I should see the CMS 404 page

  Scenario: A guest accesses a protected page
    Given a protected page at "/protected-page" exists
    When I request /protected-page
    Then I should see the CMS :forbidden page

  Scenario: View Older Versions
    Given a bug: Need to make the toolbar display when looking at older versions. (Alternative UX: Leave as is and require that users 'rollback' from the list.)
    Given a page exists with two versions
    And I am logged in as a Content Editor
    When I view version 1 of that page
    Then the toolbar should display a revert to button

  @page-caching
  Scenario: A Guest tries to access a CMS page in production
    Given a page at "/about-us" exists
    When a guest visits "http://cms.mysite.com/about-us"
    Then they should be redirected to "http://mysite.com/about-us"
    And the response should be 200

  @page-caching
  Scenario: A registered user tries to access a CMS page in production
    Given a page at "/about-us" exists
    When a registered user visits "http://cms.mysite.com/about-us"
    Then they should be redirected to "http://mysite.com/about-us"
    And the response should be 200

  @page-caching
  Scenario: Guest accesses a CMS action on the public domain
    When I visit "http://www.mysite.com/cms/dashboard"
    Then they should be redirected to "http://cms.mysite.com/cms/login"
    And the response should be 200

  @page-caching
  Scenario: Editor accesses the 'home' controller
    Given I am logged in as a Content Editor on the admin subdomain
    When I visit "http://mysite.com/cms"
    Then they should be redirected to "http://cms.mysite.com/"
    And the response should be 200