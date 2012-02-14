Feature: Upgrading BrowserCMS

  Background:
    Given I am working on a BrowserCMS v3.3.x module named "bcms_petstore"

  Scenario: Verify a Rails 3.0 app was created
    Then the following directories should exist:
      | script |
      | app    |
    And the following files should exist:
      | config.ru |

  #@announce
  Scenario: Upgrade a Module to BrowserCMS 3.4
    When I run `bcms-upgrade upgrade`
    Then the file "script/rails" should contain "test/dummy/script/rails"
    And the following files should not exist:
      | config.ru                                 |
      | MIT-LICENSE                               |
      | README.rdoc                               |
      | config/database.yml                       |
      | app/controllers/application_controller.rb |
      | app/helpers/application_helper.rb         |
      | app/views/layouts                         |
  # Confirm a Rails 3 mountable app was created
    And the following directories should exist:
      | app/assets/javascripts |
      | test/dummy |
    And the following directories should not exist:
      | public |
    And the file "test/dummy/config/database.yml" should contain "@original-yml"
    And the file "config/routes.rb" should not contain "@original-routes"
    And the file "config/routes.rb" should contain "BcmsPetstore::Engine.routes.draw"
    And the file "lib/bcms_petstore/engine.rb" should contain "require 'browsercms'"
    And the file "lib/bcms_petstore/engine.rb" should contain "@original-engine"
    And the file "lib/bcms_petstore/version.rb" should contain "@original-version"
    And the file "app/assets/test.html" should contain "@original-html"
    And the file "app/assets/js/test.js" should contain "@original-js"
    And the file "test/dummy/config/routes.rb" should contain "mount_browsercms"
    And the following files should not exist:
    | db/migrate/20080815014337_browsercms_3_0_0.rb |
    | db/migrate/20091109175123_browsercms_3_0_5.rb |
    | db/schema.rb |
    | db/seeds.rb |
    | db/development.sqlite3 |
    And the following files should exist:
    | db/migrate/my_module_migration.rb |
    And the file "bcms_petstore.gemspec" should contain "@original-gemspec"
    And the following files should exist:
    | test/dummy/db/seeds.rb |






