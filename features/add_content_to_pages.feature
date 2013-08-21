Feature: Add Content to Pages
  Content Editors should be able to add content to pages.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Selecting an existing html block
    Given there is an Html Block with:
      | name        | content     |
      | Hello World | I'm content |
    And there is a page with:
      | path       | name      |
      | /some-page | Some Page |
    When I am editing the page at /some-page
    And I choose to reuse content
    Then I should see the following content:
      | Hello World |

  Scenario: Add Html/Text to a page
    Given there is a page with:
      | path       | name      |
      | /some-page | Some Page |
    When I am editing the page at /some-page
    And I choose to add a new 'Text' content type to the page
    Then I should see a page titled "Content Library / Add New Text"
    And I should see the following content:
      | Name |
      | Text |
    When I fill in "Name" with "Hello"
    And I fill in "Content" with "I'm some new content"
    And I press "Save"
    Then I should see a page titled "Some Page"
    And the page content should contain "I'm some new content"


