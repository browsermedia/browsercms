Task: As an editor, I should be able to create events, products, etc, and have them be accessible at a given path.
Intent: Make it easier to create custom content types (like News)


* [BUG] Can't save a block as not in draft once its been created.
* Need to show draft of block when not logged in and not looking at the preview.
* Select a template to view a content type. Use the same template for each instance.
* Need a way to get back to list of 'Products'.
* [BUG] Preview doesn't work on contentblock#index
* Handle custom routes (like news /news/:year/:month/:day/:slug)
* [BUG] If product is first item in section, menus will not link to the correct location.
* [BUG] When viewing a page, and deleting it, it doesn't confirm.

Nomenclature:

* Sitemap: Edit Page vs Edit Properties (How about 'Edit' and 'configure')

## TBDs

* Add a 'Side Effects' hint when creating an addressable block that a section will be created. (i.e. This will create a new Section called '/catalog')
* Decide whether HTML/Portlets/etc should be addressable or not.
* [3] Show usage data on toolbar. (Not sure if this should be done or not)

## Nice to haves

* Autosuggest slugs based on name.
* Automatically insert :path field after name (avoid manual insertion). Use javascript or attach to :name (for addressable blocks) to insert this once a user starts typing into Name field.

## Documentation

### To make a block addressable:

Content blocks can created with as their own pages. To make a block addressable, a developer must do the following:

1. Add is_addressable path: "/some-relative-path" to the model
2. Add <%= f.cms_path_field :slug %> to the _form.html.erb for the given model.