## Tests

### Broken Features (6F):

All of these are commandline based.

cucumber features/commands/install_browsercms.feature:13 # Scenario: Install CMS into existing project

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
