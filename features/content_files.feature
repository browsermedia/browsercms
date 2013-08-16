Feature: Content Files
  The content management system should serve text and other uploaded files.

  Background:

  Scenario: Serve Text Files
    Given a text file named "/test.txt" exists with:
    """
    Test Content
    """
    When I request /test.txt
    Then I should see "Test Content"

  Scenario: Guests viewing protected file
    Given a protected text file named "/test.txt" exists with:
    """
    Test Content
    """
    When I request /test.txt
    Then the response should be 403
    And I should see a page named "Access Denied"

  Scenario: Authorized users viewing protected file
    Given a protected text file named "/test.txt" exists with:
    """
    Test Content
    """
    When login as an authorized user
    And I request /test.txt
    Then the response should be 200
    And I should see "Test Content"

  Scenario: Guests viewing an Archived file
    Given an archived file named "/test.txt" exists
    When I request /test.txt
    Then I should see the CMS 404 page