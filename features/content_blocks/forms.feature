Feature: Forms

  Editors should be able to create and manage forms to collect information from site visitors. They should be able
  to build these forms dynamically through the UI.

  Background:
    Given I am logged in as a Content Editor

  Scenario: List Forms
    Given I had created a form named "Contact Us"
    When I select forms from the content library
    Then I should see the list of forms
    And I should see the "Contact Us" form in the list

  Scenario: Add Form
    When I am adding new form
    And I enter the required form fields
    Then after saving I should be redirect to the form page

  Scenario: Edit Form
    Given I had created a form named "Contact Us"
    When I edit that form
    And I make changes to the form
    Then I should see the form with the updated fields



