Feature: Content Pages
  Visitors should be able to see content pages

  # This should be ported from test/functional/content_controller_test.rbover time.

  Background:
    Given the cms database is populated

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
