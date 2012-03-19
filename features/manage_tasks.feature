Feature: Manage Tasks
  Content Editors should be able to assign and complete tasks.

  Background:
    Given the cms database is populated
    And I am logged in as a Content Editor

  Scenario: Assign Home Page as a Task
  # This is hard coded, since the buttons/nav are in an iframe
    When I request /cms/pages/1/tasks/new
    Then I should see a page titled "Assign Page 'Home'"
    When I select "CMS Administrator (cmsadmin)" from "Assign To"
    And I press "Save"
    Then I should see a page titled "Home"
    And I should not see the following content:
      | error |
    When I request /cms/dashboard
    Then I should see the following content:
      | Home |
    And I should not see the following content:
      | You currently have no assigned tasks. |
   




