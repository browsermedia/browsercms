@cli
Feature:
  Developers should be able to upgrade from 3.4.x to 3.5.x easily.

  Background:
    Given I am working on a BrowserCMS v3.4.x project named "petstore"

  Scenario: Upgrade Project
    When I run the bcms update script
    And it should remove the default cache directory















