Task: As an editor, I should be able to create events, products, etc, and have them be accessible at a given path.

* [1] Test behavior for other blocks (This seems to mostly work, but need a bit more testing)
* [2] Show Publish status on the toolbar.
* [3] Show usage data on toolbar. (Not sure if this should be done or not)
* [BUG] Clicking on link from 'view' block doesn't reset the frame.
* Need to show draft of block when not logged in and not looking at the preview.
* Select a template to view a content type. Use the same template for each instance.
* Need a way to get back to list of 'Products'.
* [BUG] Preview doesn't work on contentblock#index

## Nice to haves

* Autosuggest slugs based on name.
* Automatically insert :path field after name (avoid manual insertion). Use javascript or attach to :name (for addressable blocks) to insert this once a user starts typing into Name field.

## Documentation

### To make a block addressable:

1. Add is_addressable path: "/some-relative-path" to the model
2. Add <%= f.cms_path_field :slug %> to the _form.html.erb for the given model.