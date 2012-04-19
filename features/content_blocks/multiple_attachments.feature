Feature: Attaching multiple assets to a block
  Blocks can be configured to allow many assets to be uploaded via a Javascript widget
  * This feature is not well tested since it requires javascript driver, which I still need to figure out.

  Background:
    Given I am logged in as a Content Editor
    And I am created a new block which allows many attachments

  Scenario: Add New Block
    Then I should see the attachment manager widget displayed

#    Scenario: Adding and deleting assets from the content manager
#      When I choose "Photos" from "asset_types"
#      And I attach the file "test/fixtures/giraffe.jpeg" to "asset_add_file"
#      Then The "photo" "giraffe.jpeg" should be added to the assets manager
#      When I choose "Spreadsheets" from "asset_types"
#
#    Scenario: Add New Assets to Game
#      When I choose "Photos" from "asset_types"
#      And I attach the file "test/fixtures/giraffe.jpeg" to "asset_add_file"
#      Then The "photo" "giraffe.jpeg" should be added to the assets manager
#      When I choose "Spreadsheets" from "asset_types"
#      Then I fill in "Name" with "An Animal"
#      Then I press "Save And Publish"
#      Then show me the page

