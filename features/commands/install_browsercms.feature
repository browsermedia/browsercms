@cli
Feature: Install BrowserCMS
  As a Rails developer who wants to add a CMS to my Rails project,
  I should be able to run a single command to have it add BrowserCMS
  In order to be up and running fast

  Background:
    Given a rails application named "petstore" exists

  Scenario: Verify
    Then a rails application named "petstore" should exist

  Scenario: Install CMS into existing project
    Given I cd to "petstore"
    And I run `bcms install --skip-bundle`
    Then BrowserCMS should be installed in the project





