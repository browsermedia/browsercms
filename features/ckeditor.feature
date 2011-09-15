Feature: CKEditor
  In order to allow non-technical users to edit HTML content
  the open source CKEditor (WYSIWYG) will be used for content that is HTML

  Scenario: Editing an Html Block
    Given the cms database is populated
    And I am logged in as a Content Editor
    When I go to the content library
    And I click on "add new content"
    Then I should see the CKEditor