Feature: Aruba Behavior
  Verifies that Aruba is configured correctly and that it is testing things as I expect them to.

  Background:

  Scenario: Create a new Rails project
    When I run `rails new hello_world --skip-bundle`
    Then a rails application named "hello_world" should exist

  Scenario: Previously generated projects should be cleaned up before each Scenario
    Then the following directories should not exist:
      | hello_world |

  Scenario: Create and verify a file exists
    Given a file named "test.txt" with:
    """
    hello
    """
    Then a file named "test.txt" should exist

  Scenario: Aruba cleans up files before each Scenario
    Then a file named "test.txt" should not exist


