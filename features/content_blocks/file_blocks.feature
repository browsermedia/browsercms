Feature: File Blocks
  So that I can serve files
  As a content editor
  I want to attach a file to a file block

  Background:
    Given I am logged in as a Content Editor
    And I am adding a new File

  Scenario: View a File block
    And the following files exist:
      | id  | name          |
      | 150 | A Sample File |
    When I visit /cms/file_blocks/150
    Then the response should be 200
    And I should see "A Sample File"
    And the file template should render

  Scenario: Creating File block
    When I fill in "Name" with "Perspective"
    And I attach the file "test/fixtures/perspective.pdf" to "File"
    And I select "My Site" from "Section"
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
    Then I should see "Path can't be blank"
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
    Then I should see "Path must be unique"

  Scenario: Looking at older versions
    Given a file exists with two versions
    When I view the first version of that file
    Then I should see the first version of the file