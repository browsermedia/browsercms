Feature: File Blocks
  So that I can serve files
  As a content editor
  I want to attach a file to a file block

  Background:
    Given I am logged in as a Content Editor
    And I am adding a new File

    Scenario: Creating File block
      When I fill in "file_block_name" with "Perspective"
      And I attach the file "test/fixtures/perspective.pdf" to "File"
      And I select "My Site" from "section_id"
      And I fill in "Path" with "/perspective.pdf"
      And I Save And Publish
      Then I should see "File 'Perspective' was created"
      And I should see an image with path "/images/cms/icons/file_types/pdf.png"
      And the attachment "perspective.pdf" should be in section "My Site"
      And There should be a link to "/perspective.pdf"

    Scenario: Creating a File block with errors
      When I Save And Publish
      Then I should see "Name can't be blank"
      When I fill in "Name" with "Perspective"
      And I Save And Publish
      Then I should see "You must upload a file"
      When I attach the file "test/fixtures/perspective.pdf" to "File"
      And I Save And Publish
      Then I should see "file path can't be blank"
      When I fill in "Path" with "/pdfs/perspective.pdf"
      And I attach the file "test/fixtures/perspective.pdf" to "File"
      And I Save And Publish
      Then I should see "File 'Perspective' was created"

    Scenario: Creating file block with non unique path
      Given a file block with path "/perspective.pdf" exists
      And I am adding a new File
      When I fill in "Name" with "Perspective"
      And I attach the file "test/fixtures/perspective.pdf" to "File"
      And I fill in "Path" with "/perspective.pdf"
      When I Save And Publish
      Then I should see "file path has already been taken"
