Feature: Image Blocks
  So that I can create image blocks
  As a content editor
  I want to upload an image

  Background:
    Given I am logged in as a Content Editor
    And I am adding a New Image

  Scenario: Add New Image
    Then I should see a page titled "Content Library / Add New Image"

  Scenario: Creating image block
    When I fill in "Name" with "Giraffe"
    And I upload an image named "test/fixtures/giraffe.jpeg"
    And I select "My Site" from "Section"
    And I fill in "Path" with "/giraffe.jpeg"
    And I Save And Publish
    Then I should see "Image 'Giraffe' was created"
    And I should see an image with path "/giraffe.jpeg"
    And the attachment with path "/giraffe.jpeg" should be in section "My Site"

  Scenario: Missing Name
    When I Save And Publish
    Then I should see "Name can't be blank"

  Scenario: Missing File
    When I fill in "Name" with "Giraffe"
    And I fill in "Path" with "/giraffe.jpg"
    And I Save And Publish
    Then I should see "You must upload a file"

  Scenario: Missing Path
    When I fill in "Name" with "Giraffe"
    And I upload an image named "test/fixtures/giraffe.jpeg"
    And I Save And Publish
    Then I should see "Path can't be blank"

  Scenario: With Existing Path
    Given an image with path "/giraffe.jpeg" exists
    And I am adding a New Image
    When I fill in "Name" with "Giraffe"
    And I upload an image named "test/fixtures/giraffe.jpeg"
    And I fill in "Path" with "/giraffe.jpeg"
    When I Save And Publish
    Then I should see "Path must be unique."

