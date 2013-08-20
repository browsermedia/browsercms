@cli
Feature: Upgrading BrowserCMS
  As a developer who has a lot of module to maintain, I really don't want to have to work off a checklist and
  would rather have an idiot proof script that will upgrade my module for me.

  Background:
    Given I am working on a BrowserCMS v3.3.x module named "bcms_petstore"

  Scenario: Verify a Rails 4.0 app was created
    Then the following directories should exist:
      | bin |
      | app    |
    And the following files should exist:
      | config.ru |








