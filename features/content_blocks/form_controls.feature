Feature: Form Controls
  In order to allow developers to create custom forms,
  BrowserCMS should provide form controls for editing content blocks
  These controls should function similar to Rails Form Helpers, but be styled for the CMS

  Background: 
    Given I am logged in as a Content Editor

  Scenario: Default File Field
    Given I am adding a new File
    Then I should see a label named "File"
    And I should see a file upload button
    And I should see the following instructions:
    | Select a file to upload |

  Scenario: Setting a label named 'Name' for File Field
    Given I am adding a New Image
    Then I should see a label named "Image"

  Scenario: Multiple Individual Attachments
    Given I am creating a new block which has two attachments
    Then I should see two file uploads

  Scenario: Edit content with multiple attachments
    Given a block exists with two uploaded attachments
    When I edit that block
    Then I should see two file uploads

  Scenario: Updating multiple attachments
    Given a block exists with two uploaded attachments
    And I replace both attachments
    Then I should see the new attachments when I view the block

  Scenario: Create with only one attachment
    Given I am creating a new block which has two attachments
    And I upload a single attachment
    When I edit that block
    Then I should see two file uploads




