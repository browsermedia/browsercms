@cli
Feature:
  As a new user of BrowserCMS, I want to be able to experiment with the system by creating a demo site.
  This demo site should have a basic look and feel, and some pages and content to play with, all of which are
  designed to show off some of the features of the system.

  Background:

  Scenario: Forgot to specify a name
    When I run `bcms demo`
    Then the output should contain:
    """
    Usage: "bcms demo [NAME]"
    """
    And the exit status should be 0

  Scenario: Make a demo project
    When I run `bcms demo petstore`
    Then a demo project named "petstore" should be created
    When I run `rake db:install`
    Then it should seed the BrowserCMS database
    And it should seed the demo data








