Feature: Form Controls
  In order to allow developers to create custom forms,
  BrowserCMS should provide form controls for editing content blocks
  These controls should function similar to Rails Form Helpers, but be styled for the CMS

  Background: 
    Given I am logged in as a Content Editor

  Scenario: File Field Helper
    Given I am adding a new File
    Then I should see a label named "File"
    And I should see a file upload button
    And I should see the following instructions:
    | Select a file to upload |


