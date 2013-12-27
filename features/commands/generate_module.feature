@cli
Feature: Generate Module
  A developer should be able to create a new BrowserCMS module by using a command line tool.

  Background:

  # bin/browsercms module Doesn't put the initializer into test/dummy app, so the layout generator fails.
  # Puts it in ./config/initializers like its a rails project.
  @known-bug
  Scenario: Create a BrowserCMS module
    When I create a module named "bcms_store"
    Then a rails engine named "bcms_store" should exist
    And BrowserCMS should be added the .gemspec file
    And a file named "bcms_store/test/dummy/app/views/layouts/templates/default.html.erb" should exist

  Scenario: Generate a module (3.4.x)
    Given I create a module named "bcms_widgets"
    Then I cd to "bcms_widgets"
    And a Gemfile should be created
    And the engine should be created
    And the installation script should be created
    And the following files should exist:
    | COPYRIGHT.txt |
    And the project should be LGPL licensed
    And the following files should exist:
    | test/dummy/db/browsercms.seeds.rb|
    And it should no longer generate a README in the public directory
    And the file "test/dummy/config/routes.rb" should contain:
    """
    Rails.application.routes.draw do

      mount BcmsWidgets::Engine => "/bcms_widgets"

      mount_browsercms
    """

  Scenario: Can Install modules
    Given I run `bcms module bcms_widgets`
    And I cd to "bcms_widgets"
    When I run `rake db:install`
    Then it should seed the BrowserCMS database

  Scenario: Packaging Modules as Gems
    Given I run `bcms module bcms_widgets`
    And I cd to "bcms_widgets"
    Then the file "bcms_widgets.gemspec" should contain "s.files -= Dir['lib/tasks/module_tasks.rake']"
    # Better tests, build the gem, check for errors
    # Install the gem, check the contents.









