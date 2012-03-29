Feature: Manage Image Blocks
  Content editors should be able to upload images into the content library.

  Background:
    Given I am logged in as a Content Editor
    And the following images exist:
      | id  | name               |
      | 150 | An LOL Cat Picture |
    Then an image with id "150" should exist

  Scenario: List Images
    When I visit /cms/image_blocks
    Then I should see a page titled "Content Library / List Images"
    And I should see the following content:
      | An LOL Cat Picture |
    And I should see the section search filter

  Scenario: Add New Image
    Given I visit /cms/image_blocks/new
    Then I should see a page titled "Content Library / Add New Image"

  Scenario: Edit an Image
    When I visit /cms/image_blocks/150/edit
    Then I should see a page titled "Content Library / Edit Image"
    And the page header should be "Edit Image 'An LOL Cat Picture'"

  Scenario: Move an Image to another Section
    And the following sections exist:
      | name          |
      | Image Gallery |
    When I visit /cms/image_blocks/150/edit
    And I select "Image Gallery" from "Section"
    And I click on "Save"
    Then the section 150 should be moved to "Image Gallery"

  Scenario: With Existing P ath
    Given an image with path "/giraffe.jpeg" exists
    And I am adding a New Image
    When I fill in "Name" with "Giraffe"
    And I attach the file "test/fixtures/giraffe.jpeg" to "File"
    And I fill in "Path" with "/giraffe.jpeg"
    When I Save And Publish
    Then I should see "file path has already been taken"





