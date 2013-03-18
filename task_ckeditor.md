## Issue #566: Add Ckeditor inline editing

### Question

* For developers, should we continue to call it text?

### Features

* No need to toggle the editor on/off. Just click the area of the page you want to edit.
* Full Edit - Click to edit in full text editor. Any changes made will be saved before going to the full editor. There is also a edit button on each block in the upper right hand corner.
* Remove blocks from page - Editors can select a block then remove it from the page via a button on the editor. Users will be prompted before its removed.
* Reorder content - Can move content blocks up or down within a page. Page will refresh after moving.
* Edit Page titles - Page title can be edited directly from the header.
* New Template API Method: page_header(). Used for h1/h2 etc, this will output an editable page title element (for logging in users).
* Preview Page - Editors can now preview the page without a toolbar or editing controls.

### Deprecations

* page_title("Some Name") is deprecated in favor of use_page_title("Some Name") for overriding a page title. This will be remove in 4.1.

### ToDo

* [BUG] Can't move portlets up/down.
* [BUG][Minor] Inline (i.e. product.name) fields display have a <p> tag added by ckeditor, so they display as block elements. This might go away if we don't embed content blocks.
* [BUG] Updating the page_header does not immediately update the <title> element.
* [Minor] Block Orders - Disable button based on position (i.e. Can't move first block up, last block down)
* [BUG] Adding the same block twice to a page screws things up.
* [BUG] Editing a block, then moving a block will throw an error. (Connector ids change between page versions)[Suggest: After editting block, replace container with new content)
* View as Mobile? - Does this still work?
* [BUG] On 'View Block'/'Edit Block' List Versions button is broken (for products)

#### Styling Concerns

* Add Content popup needs styling
* Flash message should be a popdown
* Modal window doesn't black out back.
* Better 'Add Content' icon (over plus)

#### Other Desired Features

* Edit Page - Show all editable components on a page (title, etc).

### Bugs

A. Removing/re-add block from page and it won't update
B. 500 error after editing and removing a block
C. Save And Publish from editing a block doesn't publish the block.

A. Removing/re-add block from page and it won't update   (Versioning bug?)

I observed this during testing but was unable to recreate. Might have been a data issue.

Possible Steps:
    1. Add text to homepage
    2. Edit it several times
    3. Remove it
    4. Readd it to the page
    5. Try to edit it

    Observed: 'Old' version of the block would still be shown.

B. 500 error after editing and removing a block

