Feature: Attaching multiple assets to a block
  Blocks can be configured to allow many assets to be uploaded via a Javascript widget
  * This feature is not well tested since it requires javascript driver, which I still need to figure out.

  Background:
    Given I am logged in as a Content Editor
    And there is block which allows many attachments

  Scenario: Add New Block
    When I am created a new block
    Then I should see the attachment manager widget displayed

  Scenario: Attachment Manager Widget
    Given a block exists with a single image
    When I view that block
    Then I should see that block's image
    And I should not see the delete attachment link
    When I edit that block
    Then I should see the delete attachment link

  Scenario: A Guest accesses a public attachment
    Given an attachment exists in a public section
    And I am not logged in
    When I try to view that attachment
    Then I should see the attachment content

  Scenario: A Guest accesses a protected attachment
    Given an attachment exists in a protected section
    And I am not logged in
    When I try to view that attachment
    Then I should see the CMS :forbidden page

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

