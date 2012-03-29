@javascript
@wip
Feature: Attaching assets to new content blocks
  So that I can associate assets with custom content blocks
  As a content editor
  I want to upload assets from the new content block form

  Background:
    Given I am logged in
    And the content block "Game" exsits with the following declarations:
    """
    acts_as_content_block :belongs_to_attachment => true
    uses_paperclip

    has_attached_asset :pdf
    has_many_attached_assets :photos :styles => {:coms => "60x60#"}
    has_many_attached_assets :spreadsheets
    """
    And the form for "Game" contains:
    """
      <%= f.cms_text_field :name %>
      <%= f.cms_file_field :pdf, :label => "Pdf file" %>
      <%= f.cms_file_field :attachment_file, :label => "Attachment" %>
      <%= f.cms_asset_manager %>
    """
    And I am on the new game page

    Scenario: Adding and deleting assets from the content manager
      When I choose "Photos" from "asset_types"
      And I attach the file "test/fixtures/giraffe.jpeg" to "asset_add_file"
      Then The "photo" "giraffe.jpeg" should be added to the assets manager
      When I choose "Spreadsheets" from "asset_types"

    Scenario: Add New Assets to Game
      When I choose "Photos" from "asset_types"
      And I attach the file "test/fixtures/giraffe.jpeg" to "asset_add_file"
      Then The "photo" "giraffe.jpeg" should be added to the assets manager
      When I choose "Spreadsheets" from "asset_types"
      Then I fill in "Name" with "An Animal"
      Then I press "Save And Publish"
      Then show me the page

