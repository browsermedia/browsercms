# Design Integration

## Latest Notes

### [Ask Kyle]

* Fonts for Dashboard table headers/menus are just less bold than in design.
* Icons for:
    - Edit button (Pencil) for content
    - Links
    - Portlets - Should use 'list' icon
    - Other Content Types (Product, Catalog, Generic Document) - Ideas: Book? Newspaper? Full page?
    - Visual Indicator for a section/page can't be edited. (Currently just removing the buttons)
    - Up and down sorting icons (caret is always down)
* Need style for Checkbox groups that are labeled. See Add User.
* Tables that are too wide (/cms/routes)
* JQuery Date picker - Has no styling.
* Styling for CKEditor 'selector'.
* Need help styling 'path' element.
* Errors - Review the placement of errors on the form.
* Products
    - Photo 2 is wrapping unnecessarily (Does it without photo 1)
    - Slug path needs styling.

### IA Questions

* What Label for first element under Assets? (Assets? Asset library). Or just make Text first.
* Selecting a section always toggles. Might want to select an open section to add content to it, but not close it.
* Where should "Settings" link take user to.

## Tasks

* Squash/merge all UI design changes.
* Fix remaining critical bugs.

### Open Issues

* [BUG] (Critical) Changing passwords doesn't work
* [BUG] (Critical) List portlets includes portlets that have been deleted.
* [BUG] (Critical) Versions for project specific content types don't work. (Dummy::Product)
* [BUG] (Critical) Cannot reuse Products on pages (solution might to to just disallow?)

* [DOCUMENT or IMPROVE] SimpleForms: Label: false should always be paired with: input_html: {class: 'input-block-level'}
* [BUG] Edit content button should float right and over
* [BUG] Multiple attachments doesn't work (See Catalog)
* [BUG] Sitemap - Can remove homepage
* [BUG] Dashboard - Publishing pages without selecting on throws an error.
* [BUG] Sitemap Performance - Closing large section is slow (Products)
* [BUG] Sitemap Performance - Need to filter (or condense multiple Products into a single product).
* [BUG] Editing a block on a page, then canceling, redirects to /cms/content/1/edit rather than /cms/content/1
* [BUG] Optimistic locking for pages/blocks doesn't work.
* [BUG] Dashboard is not correctly displaying draft pages.
* [BUG] View Image is huge rather than natural size.
* [FEATURE] Sitemap - Implies you can remove sections with content. (Throws error when it fails)
* [MINOR] Groups should be listed within a cell rather than wrapping.
* [BUG] New Users -Can save users without emails, with duplicate emails and without passwords.
* [PERFORMANCE] Google Fonts - Can we include them in the project so it works locally with no internet access.

## Implied Features by Design

* Make 'Assign' on Edit page work.
* Sitemap filters
* Sitemap Hide/Archive/Publish
* Dashboard Activity / My and All
* [Assets] Filter by publish/notpublished
* [Assets] Infinite scrolling





