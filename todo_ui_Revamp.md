Tasks:

- Move sitemap items
-- Add ajax calls to move items.
-- Need to expand sections as you pass over them.
-- Need an image/section name for hover element when it leaves a parent section.

## UI Merge

* Move/drag/drop sections
* Keep open/closed/last selected state of sitemap
* Audit/Delete/merge js/cms/sitemap.js.erb
* No visual indicator of an empty section
* page_editor.css/page_content_editing.css shouldn't have been deleted.
* Can't edit the root section
* Delete old sitemap pages (_section.old.erb, etc)

## Admin Menu
* Reduce the different admin layouts (why are there so many?)
* Need to highlight active tab
* Need to highlight the active menu item
* Enforce link security for menus
* iframe means drop downs don't appear under page rather than over when editing a page.

## New Features to implement

* Implement search
* Implement notifications

## UI Open Issues

Things that need to be updated in the CSS for the new UI.

* Selecting a row in content tables have no visual indicator.
* New button looks bad when you hover over it.
* When viewing a page, the draft button is on the right (rather than left) [Bad Merge?]
* Flash messages still don't look right.
* Select boxes are not styled.
* RTE drop down isn't styled correctly
* Form pages need to be styled



# Points of Design Discussion

* What information should be visible on toolbar, what should be hidden?
* Should we turn the entire toolbar red for draft pages?

### Known Issues

1. When a user selects the page title, the block editing controls are enabled, though they do nothing. (Minor)

## 4.0 Release Testing

* Verify caching works (was refactored)
* Page editing - iframe is too long (1600px) but using 100% height is too short.

