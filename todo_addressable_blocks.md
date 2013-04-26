Task: As an editor, I should be able to create events, products, etc, and have them be accessible at a given path.

* [BUG] Clicking on link from 'view' block doesn't reset the frame.
* Need to show draft of block when not logged in and not looking at the preview.
* [3] Add route for slug to content_blocks DSL. (mount_browsercms will need to iterate over all content blocks and add blocks/:slug)
* [2] Put slug on section_nodes table.
* Test behavior for other blocks
* Select a template to view a content type. Use the same template for each instance.
* Generate a new section when adding the first item of content (rather than as a seed)
* Show Publish status and usage data on toolbar. Need a way to get back to list of 'Products'.

## Nice to haves

* Autosuggest slugs based on name.
* Automatically insert :path field after name (avoid manual insertion). Use javascript to insert this once a user starts typing into Name field.