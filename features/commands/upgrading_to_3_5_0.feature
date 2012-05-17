@cli
Feature: Upgrading should be rerunnable

  Background:
    Given a directory named "petstore"
    And I cd to "petstore"

  Scenario: Comments out rails in gem
    Given a file named "Gemfile" with:
    """
    gem 'rails', '3.1.3'
    """
    When I run the bcms update script
    Then the output should contain "Commenting out Rails dependency"
    And the file "Gemfile" should contain:
    """
    # gem 'rails', '3.1.3'
    """




