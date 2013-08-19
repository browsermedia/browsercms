## Tests

### Broken Features (21F):

cucumber features/add_content_to_pages.feature:19 # Scenario: Add Html/Text to a page
cucumber features/caching.feature:7 # Scenario: Clear Page Cache
cucumber features/ckeditor.feature:5 # Scenario: Editing an Html Block
cucumber features/commands/confirm_aruba_works.feature:6 # Scenario: Create a new Rails project
cucumber features/content_blocks/add_images.feature:10 # Scenario: Add New Image
cucumber features/content_blocks/add_images.feature:13 # Scenario: Creating image block
cucumber features/content_blocks/file_blocks.feature:10 # Scenario: View a File block
cucumber features/content_blocks/file_blocks.feature:19 # Scenario: Creating File block
cucumber features/content_blocks/file_blocks.feature:30 # Scenario: Creating a File block with errors
cucumber features/content_blocks/manage_images.feature:11 # Scenario: List Images
cucumber features/email_messages.feature:8 # Scenario: Multiple Pages
cucumber features/portlets/email_friend_portlet.feature:8 # Scenario: Add New Portlet
cucumber features/portlets/portlets.feature:27 # Scenario: Viewing a portlet
cucumber features/portlets/portlets.feature:39 # Scenario: Deleting a portlet

Need to upgrade will_paginate to fix deprecation errors before removing deprecated-finders.

## Cleanup

* Refactor and clean up schema_statements.
* Verify that we don't get empty images in production.

## Upgrading Guide:

1. Change 'match' to 'get'. Tests will prompt you, so not to worry.
2. Install the deprecated finders and other gems to help with upgrade.


## Ideas

* Failures due to removed messages prompt you with very specific documentation to fix the problem (i.e. super helpful deprecation)
