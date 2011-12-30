Feature:
  Developers should be able to define content blocks in engines and have them plug into BrowserCMS.

  Background:
    Given the cms database is populated
    And a Widgets module is mounted at /bcms_widgets
    And I am logged in as a Content Editor

  Scenario: List Widgets
    When I request /bcms_widgets/widgets
    Then I should see "List Widgets"



