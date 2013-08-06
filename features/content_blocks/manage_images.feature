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
    Then the image 150 should be moved to "Image Gallery"

  Scenario: Update the path
    When I visit /cms/image_blocks/150/edit
    And I fill in "Path" with "/another-path"
    And I Save And Publish
    Then the image 150 should be at path "/another-path"

  Scenario: Looking at older versions
    Given an image exists with two versions
    When I view the first version of that image
    Then I should see the first version of the image

  Scenario: View in a page as Guest
    Given an image exists with two versions
    And I am a guest
    When I view that image on a page
    Then I should see the latest version of the image

  Scenario: Reverted Image should be visible to guests
    Given an image exists with two versions
    When I revert the image to version 1
    And I am a guest
    When I view that image on a page
    Then I should see the latest version of the image

  Scenario: Revert an Image
    Given an image exists with two versions
    When I revert the image to version 1
    Then the image should be reverted to version 1
    Then I should see it's draft mode
    And the image should be updated to version 3

# This does not test actual file content, which it probably should






