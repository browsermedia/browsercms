Feature: Deprecated Form Inputs
  In order to avoid upgrade headaches going from v3.5.x to 4.0, have backwards compatible form inputs
  (like f.cms_text_field) that can be replaced over time by developers.

  The inputs should generate the new html but also issue deprecation warnings that point developers in the right
  direction to update their code.

  Background:
    Given I am logged in as a Content Editor

  Scenario: Create a new block using deprecated fields
    Given I'm creating content which uses deprecated input fields
    Then the form page with deprecated fields should be shown
    When I fill in all the deprecated fields
    Then a new deprecated content block should be created



