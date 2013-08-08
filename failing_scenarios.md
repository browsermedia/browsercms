## After UI Rework

Failing Scenarios:  (29)
cucumber features/mobile_templates.feature:29 # Scenario: Editors can see mobile version of page
cucumber features/mobile_templates.feature:36 # Scenario: Mobile 'mode' is sticky
cucumber features/mobile_templates.feature:43 # Scenario: Disable Mobile mode
cucumber features/mobile_templates.feature:55 # Scenario: Toolbar for mobile ready pages
cucumber features/mobile_templates.feature:60 # Scenario: Toolbar for pages without mobile templates
cucumber features/portlets/email_friend_portlet.feature:8 # Scenario: Add New Portlet
cucumber features/portlets/portlets.feature:13 # Scenario: Login portlet when logged in
cucumber features/portlets/portlets.feature:36 # Scenario: Deleting a portlet
cucumber features/portlets/portlets.feature:48 # Scenario: Editing a portlet
cucumber features/portlets/portlets.feature:95 # Scenario: Portlet errors should not blow up the page
cucumber features/portlets/portlets.feature:101 # Scenario: View Usages
cucumber features/portlets/tag_cloud_portlet.feature:7 # Scenario: Add New Portlet


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