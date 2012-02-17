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
    And the project should be LGPL licensed
    And the following files should exist:
    | test/dummy/db/browsercms.seeds.rb|
    And it should no longer generate a README in the public directory






