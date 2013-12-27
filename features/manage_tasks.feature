Feature: Manage Tasks
  Content Editors should be able to assign and complete tasks.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Assign Home Page as a Task
    When I assign the home page as a task
    Then I should see a page named "Assign Task"
    When I select "CMS Administrator (cmsadmin)" from "Assign To"
    And I click the Save button
    Then I should see a page titled "Home"
    And I should not see the following content:
      | error |
    When I request /cms/dashboard
    Then I should see the following content:
      | Home |
    And I should not see the following content:
      | You currently have no assigned tasks. |
   




