Task: As an editor, I should be able to create events, products, etc, and have them be accessible at a given path.
Intent: Make it easier to create custom content types (like News)

* Encode slugs, validate their characters.
* Handle custom routes (like news /news/:year/:month/:day/:slug)
* [BUG] If product is first item in section, menus will not link to the correct location.
* [BUG] When viewing a page, and deleting it, it doesn't confirm.
* [BUG] Check All groups doesn't work for groups.

Nomenclature:

* Sitemap: Edit Page vs Edit Properties (How about 'Edit' and 'Configure')

## TBDs

* Double clicking block should go to 'View' rather than edit.
* Decide whether HTML/Portlets/etc should be addressable or not.

## Nice to haves

* Preview Blocks behaves slightly differently that previewing pages.
    - Preview Pages opens without toolbar (/pages/1/preview) vs
    - Preview blocks opens with toolbar.
    - Might want to have 'edit' block (/cms/product/1) redirect to the path of the page (/products/abc).
    - Then Preview can just open it in a new window.


## Documentation

### To make a block addressable:

Content blocks can created with as their own pages. To make a block addressable, a developer must do the following:

1. Add is_addressable to the model. This will automatically generate a :slug form field when creating/editing instances.
2. Set the Page Template that should be used (defaults to 'default').

#### Example

class Product < ActiveRecord::Base
  is_addressable path: "/some-relative-path", template: "product"
end