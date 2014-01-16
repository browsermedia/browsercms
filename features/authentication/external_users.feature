Feature: External Users
  The CMS should allow users to login using credentials verified against external data sources.
  These data sources could be anything from a CRM, LDAP or Google/Facebook.
  Each external datasource needs a Devise strategy in order to connect with it.

  Background:

  Scenario: First login
    When I login in as an external user for the first time
    Then I should be successful
    And it should create an external user record in the database

  Scenario: Second and subsequent login
    Given I have already logged in once as an external user
    When I login in as an external user again
    Then it should not create any new user records in the database

  Scenario: Edit External Users
    Given an external user exists
    And I am logged in as a Content Editor
    When I edit that external user
    Then I should be able to change some fields
