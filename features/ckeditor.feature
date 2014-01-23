Feature: CKEditor
  In order to allow non-technical users to edit HTML content
  the open source CKEditor (WYSIWYG) will be used for content that is HTML

  Scenario: Editing an Html Block
    Given I am logged in as a Content Editor
    When I request /cms/content_library
    And I click on "create_new_html_block"
    Then I should see a widget to select which editor to use
