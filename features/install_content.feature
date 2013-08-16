Feature: Install blank site
  	As a developer installing BrowserCMS
	there should be an initial set of starting data
	so that there is a starting point for creating content.

  Background:

  Scenario: A homepage should exist
    Given I am on the homepage
    Then I should see a page named "Home"

  Scenario: An error page should exist
    Given I am at /system/server_error
    Then I should see a page named "Server Error"

  Scenario: A 404 page should exist
    Given I am at /system/not_found
    Then I should see a page named "Page Not Found"






