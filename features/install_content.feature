Feature: Install blank site
  	As a developer installing BrowserCMS
	there should be an initial set of starting data
	so that there is a starting point for creating content.

  Scenario: A homepage should exist
    Given I am on the homepage
    Then I should see a page titled "Home"

  Scenario: An error page should exist
    Given I am at /system/server_error
    Then I should see a page titled "Server Error"





