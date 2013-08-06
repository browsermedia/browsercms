## After UI Rework

Failing Scenarios:  (44)
cucumber features/acts_as_content_page.feature:56 # Scenario: NotFound Page as a Content Editor
cucumber features/add_content_to_pages.feature:7 # Scenario: Selecting an existing html block
cucumber features/add_content_to_pages.feature:19 # Scenario: Add Html/Text to a page
cucumber features/commands/generate_module.feature:13 # Scenario: Generate a module (3.4.x)
cucumber features/commands/generate_module.feature:34 # Scenario: Can Install modules
cucumber features/commands/new_demo_project.feature:17 # Scenario: Make a demo project
cucumber features/commands/upgrade_project_to_3_4_0_from_3_3_x.feature:10 # Scenario: Upgrade Project
cucumber features/commands/upgrade_project_to_3_4_0_from_3_3_x.feature:32 # Scenario: Updates version table
cucumber features/commands/upgrade_project_to_3_4_0_from_3_3_x.feature:38 # Scenario: Migrations work for new project
cucumber features/commands/upgrading_to_3_5_0.feature:8 # Scenario: Comments out rails in gem
cucumber features/content_blocks/manage_html_blocks.feature:7 # Scenario: List Html Blocks
cucumber features/content_blocks/manage_html_blocks.feature:66 # Scenario: Draft Html Block
cucumber features/content_blocks/manage_images.feature:11 # Scenario: List Images
cucumber features/content_blocks/manage_images.feature:56 # Scenario: Revert an Image
cucumber features/content_blocks/multiple_attachments.feature:13 # Scenario: Attachment Manager Widget
cucumber features/content_pages.feature:23 # Scenario: View Older Versions
cucumber features/generators/attachments.feature:9 # Scenario: Single Named Attachment
cucumber features/generators/attachments.feature:31 # Scenario: Two Named Attachment
cucumber features/generators/attachments.feature:42 # Scenario: Multiple Attachments
cucumber features/generators/attachments.feature:64 # Scenario: Multiple Attachments with different names
cucumber features/generators/content_blocks_for_modules.feature:9 # Scenario: Generate content block in a module
cucumber features/generators/content_blocks_for_projects.feature:9 # Scenario: Create an content block for a project
cucumber features/generators/content_blocks_for_projects.feature:55 # Scenario: With Belongs To
cucumber features/generators/content_blocks_for_projects.feature:69 # Scenario: With Categories
cucumber features/manage_page_routes.feature:19 # Scenario: Create Page Route
cucumber features/manage_page_routes.feature:31 # Scenario: Edit Page Route
cucumber features/manage_redirects.feature:8 # Scenario: Create Redirect
cucumber features/manage_redirects.feature:21 # Scenario: Update Redirects
cucumber features/manage_tasks.feature:7 # Scenario: Assign Home Page as a Task
cucumber features/mobile_templates.feature:29 # Scenario: Editors can see mobile version of page
cucumber features/mobile_templates.feature:36 # Scenario: Mobile 'mode' is sticky
cucumber features/mobile_templates.feature:43 # Scenario: Disable Mobile mode
cucumber features/mobile_templates.feature:55 # Scenario: Toolbar for mobile ready pages
cucumber features/mobile_templates.feature:60 # Scenario: Toolbar for pages without mobile templates
cucumber features/navigation_menu/new_button.feature:23 # Scenario: Redirects
cucumber features/portlets/email_friend_portlet.feature:8 # Scenario: Add New Portlet
cucumber features/portlets/portlets.feature:9 # Scenario: List Portlets
cucumber features/portlets/portlets.feature:36 # Scenario: Deleting a portlet
cucumber features/portlets/portlets.feature:48 # Scenario: Editing a portlet
cucumber features/portlets/portlets.feature:94 # Scenario: Portlet errors should not blow up the page
cucumber features/portlets/portlets.feature:112 # Scenario: View Usages
cucumber features/portlets/tag_cloud_portlet.feature:7 # Scenario: Add New Portlet
cucumber features/taxonomy/manage_categories.feature:7 # Scenario: Add New Category
cucumber features/taxonomy/manage_category_types.feature:7 # Scenario: Add New Category Type


## After Inline Editing
List of broken scenarios as of 3/19/2013 (After #566 inline editing is done)

cucumber features/add_content_to_pages.feature:7 # Scenario: Selecting an existing html block
cucumber features/add_content_to_pages.feature:19 # Scenario: Add Html/Text to a page
cucumber features/commands/generate_module.feature:13 # Scenario: Generate a module (3.4.x)
cucumber features/commands/upgrade_project_to_3_4_0_from_3_3_x.feature:10 # Scenario: Upgrade Project
cucumber features/commands/upgrading_to_3_5_0.feature:8 # Scenario: Comments out rails in gem
cucumber features/content_blocks/manage_custom_blocks.feature:42 # Scenario: Add to a page
cucumber features/generators/attachments.feature:9 # Scenario: Single Named Attachment
cucumber features/generators/attachments.feature:31 # Scenario: Two Named Attachment
cucumber features/generators/attachments.feature:42 # Scenario: Multiple Attachments
cucumber features/generators/attachments.feature:64 # Scenario: Multiple Attachments with different names
cucumber features/generators/content_blocks_for_modules.feature:9 # Scenario: Generate content block in a module
cucumber features/generators/content_blocks_for_projects.feature:9 # Scenario: Create an content block for a project
cucumber features/generators/content_blocks_for_projects.feature:55 # Scenario: With Belongs To
cucumber features/generators/content_blocks_for_projects.feature:69 # Scenario: With Categories
cucumber features/mobile_templates.feature:29 # Scenario: Editors can see mobile version of page
cucumber features/mobile_templates.feature:36 # Scenario: Mobile 'mode' is sticky
cucumber features/mobile_templates.feature:43 # Scenario: Disable Mobile mode
cucumber features/portlets/portlets.feature:13 # Scenario: Login portlet when logged in
cucumber features/user_self_service.feature:9 # Scenario: Cannot edit other users