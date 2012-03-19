@cli
Feature:
  Assuming there is BrowserCMS project that is currently running 3.3.x
  the upgrade script should handle generating, and/or manipulating files to make upgrading simple

  # Note: We skip running `rake rails:update` as part of these tests since it requires an interactive
  # command as part a separate process to overwrite files, so its very hard to wait for the exact timing.

  Background:
    Given I am working on a BrowserCMS v3.3.x project named "petstore"

  Scenario: Upgrade Project
    When I run `bcms upgrade --skip-rails`
    Then Gemfile should have the correct version of BrowserCMS
    And it should comment out Rails in the Gemfile
    And it should run bundle install
    And it should copy all the migrations into the project
    And it should add the seed data to the project
    And it should display instructions to the user

  Scenario: Projects with Content Block
    Given the project has a "turtle" block
    When I run `bcms upgrade --skip-rails`
    Then I should have a migration for updating the "turtle" versions table

  Scenario: Projects with Content Blocks and Models
    Rails models (that aren't blocks) should not have a migration generated for them.

    Given the project has a "turtle" block
    And the project has a "category" model
    When I run `bcms upgrade --skip-rails`
    Then I should have a migration for updating the "turtle" versions table

  Scenario: Updates version table
    Given the project has a "turtle" block
    When I run `bcms upgrade  --skip-rails`
    When I run `rake db:migrate`
    Then the migration should update the version table for "turtle" block

  Scenario: Migrations work for new project
    Given the project has a "turtle" block which hasn't ever been migrated
    When I run `bcms upgrade  --skip-rails`
    When I run `rake db:migrate`
    Then the migration should not update the version table for "turtle" block








