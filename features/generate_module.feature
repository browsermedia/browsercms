@cli
Feature: Generate Module
  A developer should be able to create a new BrowserCMS module by using a command line tool.

  Background:

  Scenario:
    Given I run `bcms module bcms_widgets`
    Then I cd to "bcms_widgets"
    And a Gemfile should be created
    And the engine should be created
    And the installation script should be created
    And the following files should exist:
    | COPYRIGHT.txt |
    | GPL.txt |
    | LICENSE.txt |





