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


