@cli
Feature: Upgrade Module from 3.1.x to 3.4.x

  Background:
    Given I am working on a BrowserCMS v3.1.x module named "bcms_widgets"

  Scenario: Verify Project
    Then a file named "script/console" should exist

  Scenario: Upgrade a Module from 3.1.x to 3.4.x
    When I run `bcms-upgrade module`
    Then the output should contain "Upgrading to BrowserCMS 3.3.x"
    And a Gemfile should be created
    And the engine should be created
    And the installation script should be created




