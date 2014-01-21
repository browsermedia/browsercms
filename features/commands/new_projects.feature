@cli
Feature: New Project Generator
  Developers should be able to create new projects from the command line.

  Background:

  Scenario: Output the Version
    When I run `bcms -v`
    Then it should display the current version of BrowserCMS

  Scenario: Create a new BrowserCMS project
    When I create a new BrowserCMS project named "hello"
    Then a rails application named "hello" should exist
    And a file named "public/index.html" should not exist
    And it should copy all the migrations into the project
    And the file "hello/config/routes.rb" should contain "mount_browsercms"
    And the file "hello/db/seeds.rb" should contain "require File.expand_path('../browsercms.seeds.rb', __FILE__)"
    And a file named "hello/db/browsercms.seeds.rb" should exist
    And a directory named "hello/hello" should not exist
    And a file named "hello/config/initializers/browsercms.rb" should exist
    And a file named "hello/app/views/layouts/templates/default.html.erb" should exist
    And a file named "hello/config/initializers/devise.rb" should exist
    And the output should not contain "identical"
    And BrowserCMS should be added the Gemfile
    And the correct version of Rails should be added to the Gemfile
    And the production environment should be configured with reasonable defaults

  Scenario: With a specific database
    When I run `bcms new hello_world -d mysql`
    Then the file "hello_world/Gemfile" should contain "mysql2"

  Scenario: With an application template
      The exact template is irrelevant, so long as bcms command passes it to rails.

      When I run `bcms new hello_world -m sometemplate.rb`
      Then the output should contain "sometemplate.rb] could not be loaded"

  Scenario: Creating a new CMS project without a  name
    When I run `bcms new`
    Then the output should contain:
    """
    Usage: "bcms new [NAME]".
    """
    And the exit status should be 0

  Scenario: Creating a CMS module without a  name
    When I run `bcms module`
    Then the output should contain:
    """
    Usage: "bcms module [NAME]".
    """
    And the exit status should be 0