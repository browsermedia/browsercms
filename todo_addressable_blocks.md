Task: As an editor, I should be able to create events, products, etc, and have them be accessible at a given path.
Intent: Make it easier to create custom content types (like News)

* Handle custom routes (like news /news/:year/:month/:day/:slug)
* [BUG] If product is first item in section, menus will not link to the correct location.
* [BUG] When viewing a page, and deleting it, it doesn't confirm.
* [BUG] Check All groups doesn't work for groups.

Nomenclature:

* Sitemap: Edit Page vs Edit Properties (How about 'Edit' and 'Configure')

## TBDs

* Double clicking block should go to 'View' rather than edit.
* Add a 'Side Effects' hint when creating an addressable block that a section will be created. (i.e. This will create a new Section called '/catalog')
* Decide whether HTML/Portlets/etc should be addressable or not.
* [3] Show usage data on toolbar. (Not sure if this should be done or not)

## Nice to haves

* Preview Blocks behaves slightly differently that previewing pages.
    - Preview Pages opens without toolbar (/pages/1/preview) vs
    - Preview blocks opens with toolbar.
    - Might want to have 'edit' block (/cms/product/1) redirect to the path of the page (/products/abc).
    - Then Preview can just open it in a new window.
* Autosuggest slugs based on name.
* Automatically insert :path field after name (avoid manual insertion). Use javascript or attach to :name (for addressable blocks) to insert this once a user starts typing into Name field.

## Documentation

### To make a block addressable:

Content blocks can created with as their own pages. To make a block addressable, a developer must do the following:

1. Add is_addressable path: "/some-relative-path" to the model
2. Add <%= f.cms_path_field :slug %> to the _form.html.erb for the given model.