## Tests

Units: 29 F, 271 E
Units: 45F, 112 E

## Cleanup

* Refactor and clean up schema_statements.
* Verify that we don't get empty images in production.

## Upgrading Guide:

1. Change 'match' to 'get'. Tests will prompt you, so not to worry.

## Rollbacks

          create_section_node(:node => self, :section => sec)
          build_section_node(:node => self, :section => sec)


## Ideas

* Failures due to removed messages prompt you with very specific documentation to fix the problem (i.e. super helpful deprecation)
