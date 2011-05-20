Feature: Install blank site
  In order to have a reasonable starting point
  a web developer
  wants a a blank site to be created with seed content.

  Scenario: A homepage exists
    Given I am on the homepage
    Then I should see a page titled "Home"

  Scenario: An error page exists
    Given I am at /system/server_error
    Then I should see a page titled "Server Error"


