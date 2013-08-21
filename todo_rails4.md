## Tests

DEPRECATION WARNING: ActionController::Integration is deprecated and will be removed, use ActionDispatch::Integration instead. (called from <top (required)> at /Users/ppeak/projects/browsercms/features/support/env.rb:40)

## Cleanup

* Refactor and clean up schema_statements.
* Verify that we don't get empty images in production.

## Upgrading Guide:

1. Change 'match' to 'get'. Tests will prompt you, so not to worry.
2. Install the deprecated finders and other gems to help with upgrade.


## Ideas

* Failures due to removed messages prompt you with very specific documentation to fix the problem (i.e. super helpful deprecation)
