Feature: Command Line
  Commands should work from the commandline

  Background:

  Scenario: Output the Version
    When I run `bcms -v`
    Then the output should contain "BrowserCMS 3.4.0"

  # `bcms new` does more than this, so could be more detailed.
  Scenario: Create a new BrowserCMS project
    When I create a new BrowserCMS project named "hello"
    Then a rails application named "hello" should exist
    And a file named "public/index.html" should not exist
    And the output should contain "rake  cms:install:migrations"
    And the output should contain "Copied migration"
    And the output should contain "browsercms300.rb from cms"
    And the output should contain "browsercms305.rb from cms"
    And the output should contain "browsercms330.rb from cms"
    And the output should contain "browsercms340.rb from cms"
    And the file "hello/config/routes.rb" should contain "mount_browsercms"
    And the file "hello/db/seeds.rb" should contain "require File.expand_path('../browsercms.seeds.rb', __FILE__)"
    And a file named "hello/db/browsercms.seeds.rb" should exist
    And a file named "hello/config/initializers/browsercms.rb" should exist
    And a file named "hello/app/views/layouts/templates/default.html.erb" should exist
    And BrowserCMS should be added the Gemfile

  # `bcms module`
  Scenario: Create a BrowserCMS module
    When I create a module named "bcms_store"
    Then a rails engine named "bcms_store" should exist
    And BrowserCMS should be added the .gemspec file
    And a file named "bcms_store/test/dummy/app/views/layouts/templates/default.html.erb" should exist


