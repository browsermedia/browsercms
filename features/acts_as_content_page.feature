Feature: Acts as Content Page
  Rails developers should be able to create standard Rails Controllers that include CMS features, including:
  1. Handling of exceptions (i.e. routing to standard CMS error pages)
  2. Security (protected controllers as if they were site pages.

  See 'Tests::PretendController' for other scenarios to pull out.

  Background:
    Given I am a guest

  Scenario: Use CMS templates with Rails Controllers
    When I visit /content-page
    Then the response should be 200
    And I should see a page titled "ContentPage"
    And I should see the following content:
      | Dummy Site Template |

  Scenario: Set a Page Title
    When I visit /custom-page
    Then I should see a page titled "My Custom Page"
    And I should see the following content:
    | Some Custom Content |

  Scenario: Content Page
    When I visit /tests/open
    Then the response should be 200
    Then I should see the following content:
      | Open Page                     |
      | You can see this public page. |


  Scenario: Error Page
    When I am at /tests/error
    Then the response should be 500
    And I should see a page titled "Server Error"
    And I should see the following content:
      | The server encountered an unexpected condition that prevented it from fulfilling the request. |

  Scenario: Controller throws Missing Page Error
    When I am at /tests/not-found
    Then the response should be 404
    And I should see a page titled "Not Found"
    And I should see the following content:
      | Page Not Found |


  Scenario: A Controller in a 'Restricted' section
    Given a members only section
    When I am at /tests/restricted
    Then the response should be 403
    And I should see a page titled "Access Denied"
    And I should see the following content:
      | Access Denied |


  Scenario: NotFound Page as a Content Editor
    Given I am logged in as a Content Editor
    When I visit /tests/not-found
    Then the response should be 404
    And I should see a page titled "Error: ActiveRecord::RecordNotFound"

