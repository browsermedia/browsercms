Feature: Serve Pages
  The content management system should serve content

  Background:
    Given the cms database is populated


  Scenario: Serve Text Files
    Given a text file named "/test.txt" exists with:
    """
    Test Content
    """
    When I request /test.txt
    Then I should see "Test Content"

  Scenario: A File in a protected section
    Given a protected text file named "/test.txt" exists with:
    """
    Test Content
    """
    When I request /test.txt
    Then the response should be 403
    And I should see a page titled "Access Denied"


