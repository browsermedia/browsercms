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

* [BUG][Minor] Inline (i.e. product.name) fields display have a <p> tag added by ckeditor, so they display as block elements. This might go away if we don't embed content blocks.
* [Improvement][Minor] Block Orders - Disable button based on position (i.e. Can't move first block up, last block down)
* [BUG][Trivial] If the same block appears twice on the same page, inline editing one will not cause the other to immediately show the update. (This is probably so rare as to be a non-issue anyway.)

### General UI issues

* [BUG] View versions of blocks has no toolbar.
* [BUG] On 'View Block'/'Edit Block' List Versions button is broken (for products)
* View as Mobile? - Does this still work?

#### Styling Concerns

* Add Content popup needs styling
* Flash message should be a popdown
* Modal window doesn't black out back.
* Better 'Add Content' icon (over plus)

### Bugs

A. Removing/re-add block from page and it won't update
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


