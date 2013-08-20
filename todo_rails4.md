## Tests

### Broken Features (6F):

All of these are commandline based.

cucumber features/commands/generate_module.feature:7 # Scenario: Create a BrowserCMS module
cucumber features/commands/install_browsercms.feature:13 # Scenario: Install CMS into existing project
cucumber features/commands/upgrade_modules_to_3_4_0_from_3_1_x.feature:10 # Scenario: Upgrade a Module from 3.1.x to 3.4.x
cucumber features/commands/upgrading_modules.feature:9 # Scenario: Verify a Rails 3.0 app was created
cucumber features/commands/upgrading_modules.feature:24 # Scenario: Upgrade a Module from 3.3.x to 3.4.x
cucumber features/generators/content_blocks_for_modules.feature:9 # Scenario: Generate content block in a module

Need to upgrade will_paginate to fix deprecation errors before removing deprecated-finders.

## Cleanup

* Refactor and clean up schema_statements.
* Verify that we don't get empty images in production.

## Upgrading Guide:

1. Change 'match' to 'get'. Tests will prompt you, so not to worry.
2. Install the deprecated finders and other gems to help with upgrade.


## Ideas

* Failures due to removed messages prompt you with very specific documentation to fix the problem (i.e. super helpful deprecation)
