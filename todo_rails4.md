## Tests

### Broken Features (66):

cucumber features/acts_as_content_page.feature:32 # Scenario: Error Page
cucumber features/add_content_to_pages.feature:19 # Scenario: Add Html/Text to a page
cucumber features/caching.feature:7 # Scenario: Clear Page Cache
cucumber features/ckeditor.feature:5 # Scenario: Editing an Html Block
cucumber features/commands/confirm_aruba_works.feature:6 # Scenario: Create a new Rails project
cucumber features/commands/generate_module.feature:7 # Scenario: Create a BrowserCMS module
cucumber features/commands/install_browsercms.feature:10 # Scenario: Verify
cucumber features/commands/install_browsercms.feature:13 # Scenario: Install CMS into existing project
cucumber features/commands/new_demo_project.feature:9 # Scenario: Forgot to specify a name
cucumber features/commands/new_demo_project.feature:17 # Scenario: Make a demo project
cucumber features/commands/new_projects.feature:11 # Scenario: Create a new BrowserCMS project
cucumber features/commands/new_projects.feature:36 # Scenario: Creating a new CMS project without a  name
cucumber features/commands/new_projects.feature:44 # Scenario: Creating a CMS module without a  name
cucumber features/commands/upgrade_modules_to_3_4_0_from_3_1_x.feature:10 # Scenario: Upgrade a Module from 3.1.x to 3.4.x
cucumber features/commands/upgrading_modules.feature:9 # Scenario: Verify a Rails 3.0 app was created
cucumber features/commands/upgrading_modules.feature:24 # Scenario: Upgrade a Module from 3.3.x to 3.4.x
cucumber features/content_blocks/add_images.feature:10 # Scenario: Add New Image
cucumber features/content_blocks/add_images.feature:13 # Scenario: Creating image block
cucumber features/content_blocks/file_blocks.feature:10 # Scenario: View a File block
cucumber features/content_blocks/file_blocks.feature:19 # Scenario: Creating File block
cucumber features/content_blocks/file_blocks.feature:30 # Scenario: Creating a File block with errors
cucumber features/content_blocks/manage_html_blocks.feature:17 # Scenario: Save but not publish a New Block
cucumber features/content_blocks/manage_html_blocks.feature:28 # Scenario: Publishing a New Block
cucumber features/content_blocks/manage_html_blocks.feature:39 # Scenario: Publishing an existing block
cucumber features/content_blocks/manage_images.feature:11 # Scenario: List Images
cucumber features/content_blocks/manage_pages.feature:7 # Scenario: Edit Page
cucumber features/content_blocks/manage_pages.feature:11 # Scenario: Creating Page as unpublished
cucumber features/content_blocks/manage_pages.feature:15 # Scenario: Publishing a Page (which was unpublished)
cucumber features/email_messages.feature:8 # Scenario: Multiple Pages
cucumber features/generators/attachments.feature:9 # Scenario: Single Named Attachment
cucumber features/generators/attachments.feature:31 # Scenario: Two Named Attachment
cucumber features/generators/attachments.feature:42 # Scenario: Multiple Attachments
cucumber features/generators/attachments.feature:64 # Scenario: Multiple Attachments with different names
cucumber features/generators/content_blocks_for_modules.feature:9 # Scenario: Generate content block in a module
cucumber features/generators/content_blocks_for_projects.feature:9 # Scenario: Create an content block for a project
cucumber features/generators/content_blocks_for_projects.feature:55 # Scenario: With Belongs To
cucumber features/generators/content_blocks_for_projects.feature:69 # Scenario: With Categories
cucumber features/generators/content_blocks_for_projects.feature:83 # Scenario: With Html attributes
cucumber features/generators/content_blocks_for_projects.feature:88 # Scenario: Block names starting with 'do' should work
cucumber features/generators/templates.feature:9 # Scenario: Generate Template
cucumber features/generators/templates.feature:13 # Scenario: Generate Mobile template
cucumber features/manage_groups.feature:7 # Scenario: Create a new content editor group
cucumber features/manage_page_routes.feature:19 # Scenario: Create Page Route
cucumber features/manage_page_routes.feature:31 # Scenario: Edit Page Route
cucumber features/manage_redirects.feature:8 # Scenario: Create Redirect
cucumber features/manage_redirects.feature:21 # Scenario: Update Redirects
cucumber features/manage_sections.feature:7 # Scenario: Create Section
cucumber features/manage_tasks.feature:7 # Scenario: Assign Home Page as a Task
cucumber features/mobile_templates.feature:10 # Scenario: Desktop Visitor sees Desktop template
cucumber features/mobile_templates.feature:15 # Scenario: Browsing mobile site pages
cucumber features/mobile_templates.feature:20 # Scenario: Browsing the desktop site with a mobile browser
cucumber features/mobile_templates.feature:26 # Scenario: Browsing a page on mobile site without a mobile template
cucumber features/mobile_templates.feature:32 # Scenario: Editors can see mobile version of page
cucumber features/mobile_templates.feature:39 # Scenario: Mobile 'mode' is sticky
cucumber features/mobile_templates.feature:46 # Scenario: Disable Mobile mode
cucumber features/mobile_templates.feature:53 # Scenario: Guests can't request mobile versions of page
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
