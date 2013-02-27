## Issue #566: Add Ckeditor inline editing

### Question

* For developers, should we continue to call it text?

### Features

* No need to toggle the editor on/off. Just click the area of the page you want to edit.
* Full Edit - Click to edit in full text editor. Any changes made will be saved before going to the full editor.
* Remove blocks from page - Editors can select a block then remove it from the page via a button on the editor. Users will be prompted before its removed.
* Reorder content - Can move content blocks up or down within a page. Page will refresh after moving.

### ToDo

* [Minor] Block Orders - Disable button based on position (i.e. Can't move first block up, last block down)
* [BUG] Adding the same block twice to a page screws things up.
* [BUG] Editing a block, then moving a block will throw an error. (Connector ids change between page versions)[Suggest: After editting block, replace container with new content)
* Add a 'Preview' button - Open window in new tab, no UI.
* Edit page title
* Handle editing other blocks (i.e. Products)
* Link to files
* Link to images
* View as Mobile? - Does this still work?


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

