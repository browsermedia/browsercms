Feature: Acts as Content Page
  Rails developers should be able to create standard Rails Controllers that include CMS features, including:
  1. Handling of exceptions (i.e. routing to standard CMS error pages)
  2. Security (protected controllers as if they were site pages.

  See 'Tests::PretendController' for other scenarios to pull out.

  Background:
    Given the cms database is populated
    And I am a guest

  Scenario: Error Page
    When I am at /tests/error
  # I should see the standard CMS Error page for guests
    Then the response should be 500
    And I should see a page titled "Server Error"
    And I should see the following content:
      | The server encountered an unexpected condition that prevented it from fulfilling the request. |

  Scenario: Controller throws Missing Page Error
    When I am at /tests/not_found
  # I should see the standard CMS Missing page for guests
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

