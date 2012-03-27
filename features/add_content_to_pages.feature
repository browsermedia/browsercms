Feature: Add Content to Pages
  Content Editors should be able to add content to pages.

  Background:

  Scenario: Selecting an existing html block
    Given there is an Html Block with:
      | name        | content     |
      | Hello World | I'm content |
    And there is a page with:
      | path       | name      |
      | /some-page | Some Page |
    And I am logged in as a Content Editor
    And I turn on edit mode for /some-page
    When I am at /some-page
    And I click the Select Existing Content button
    Then I should see the following content:
      | Hello World |

  Scenario: Add Html/Text to a page
    Given there is a page with:
      | path       | name      |
      | /some-page | Some Page |
    And I am logged in as a Content Editor
    And I turn on edit mode for /some-page
    When I am at /some-page
    And I add new content to the page
    Then I should see the following content:
      | File    |
      | Text    |
      | Image   |
      | Portlet |
    And I should see a page titled "Select Content Type"
    When I follow "Text"
    Then I should see a page titled "Content Library / Add New Text"
    And I should see the following content:
      | Name |
      | Text |
    When I fill in "Name" with "Hello"
    And I fill in "Content" with "I'm some new content"
    And I press "Save"
    Then I should see a page titled "Some Page"
    And I should see the following content:
      | I'm some new content |
