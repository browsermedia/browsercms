Tasks:

- Move sitemap items
-- [BUG] Sometime when you move an item between lists, the moving element disappears behind the other lists. All you see is the drop target.
-- Rename new-sitemap.js to sitemap.js

## UI Merge Items
* page_editor.css/page_content_editing.css shouldn't have been deleted during the bootstrap UI merge.
* Can't edit the root section

## Admin Menu
* Reduce the different admin layouts (why are there so many?)
* Need to highlight active tab
* Need to highlight the active menu item
* Enforce link security for menus

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

