Feature: Manage Groups
  CMS Admins should be able to create and manage groups and their permissions through the UI.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Create a new content editor group
    Given I am on the groups page
    When I click on "Add Group"
    Then I should see a page named "Add a New Group"
    When I fill in "Name" with "Publisher's Group"
    And I select "CMS User" from "Type of User"
    And I check "Edit Content"
    And I check "Publish Content"
    And I check "My Site"
    And I click the Save button
    Then I should see "Publisher's Group"
    And the new group should have edit and publish permissions
    And I should see "1 of 2 Sections"

  Scenario: Create Public Group
    Given I am on the groups page
    When I click on "Add Group"
    Then I should see a page named "Add a New Group"
    When I fill in "Name" with "Authenticated Users"
    And I select "Registered Public User" from "Type of User"
    And I click the Save button
    Then I should see "Authenticated Users"
    Then I click on "Authenticated Users"
    And the new group should have neither edit nor publish permissions

  Scenario: Update Group
    Given the following group exists:
      | name    |
      | Members |
    Given I request /cms/groups
    And I click on "Members"
    And I fill in "Group Name" with "Members for Life"
    And I click the Save button
    Then I should see "Members for Life"


  Scenario: Multiple Pages of Groups
    Given there are 20 groups
    When I am at /cms/groups
    Then I should see "Displaying 1 - 15 of 20"
    When I click on "next_page_link"
    Then I should see "Displaying 16 - 20 of 20"