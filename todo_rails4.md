## Tests

### Broken Features (34):

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
cucumber features/manage_groups.feature:7 # Scenario: Create a new content editor group
cucumber features/manage_page_routes.feature:19 # Scenario: Create Page Route
cucumber features/manage_page_routes.feature:31 # Scenario: Edit Page Route
cucumber features/manage_redirects.feature:8 # Scenario: Create Redirect
cucumber features/manage_redirects.feature:21 # Scenario: Update Redirects
cucumber features/manage_sections.feature:7 # Scenario: Create Section
cucumber features/manage_tasks.feature:7 # Scenario: Assign Home Page as a Task
cucumber features/page_templates.feature:7 # Scenario: Add a Page Template
cucumber features/page_templates.feature:19 # Scenario: Multiple pages of templates
cucumber features/page_templates.feature:26 # Scenario: Edit a template
cucumber features/portlets/email_friend_portlet.feature:8 # Scenario: Add New Portlet
cucumber features/portlets/portlets.feature:27 # Scenario: Viewing a portlet
cucumber features/portlets/portlets.feature:39 # Scenario: Deleting a portlet
cucumber features/sitemap/create_pages.feature:7 # Scenario: Create Page
cucumber features/sitemap/manage_links.feature:8 # Scenario: Add Link
cucumber features/sitemap/manage_links.feature:18 # Scenario: Update And Publish Link
cucumber features/taxonomy/manage_categories.feature:18 # Scenario: Add Category with no category types

Need to upgrade will_paginate to fix deprecation errors before removing deprecated-finders.

## Cleanup

* Refactor and clean up schema_statements.
* Verify that we don't get empty images in production.

## Upgrading Guide:

1. Change 'match' to 'get'. Tests will prompt you, so not to worry.
2. Install the deprecated finders and other gems to help with upgrade.


## Ideas

* Failures due to removed messages prompt you with very specific documentation to fix the problem (i.e. super helpful deprecation)
