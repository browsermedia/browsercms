Tasks:

## UI Merge

* [BUG] Deleting addressable content from the sitemap throws error and breaks the UI.
* Select something else after deleting.
* Handle non-editable sections (from security)
* Audit sitemap.js.erb for remaining features.
* Have something selected at the start (last selected or Root)
* Remove (or center) the lock/unlock icon for the root section
* Keep open/closed state of sitemap
* Delete/merge js/cms/sitemap.js.erb
* Move/drag/drop sections
* Enable buttons correctly based on selected item
* Selecting the root section should not change its icon or expand/collapse it.
* Paths are not autogenerating when creating products/catalogs.

##


## Bugs

- Can't edit the root section

Current Task:

* Implement implied features (Search/Notifications)

## Admin Menu
* Reduce the different admin layouts (why are there so many?)
* Need to highlight active tab
* Need to highlight the active menu item
* Enforce link security for menus
* iframe means drop downs don't appear under page rather than over when editing a page.

## New Features to implement

* Implement search
* Implement notifications

## Developer Tasks

Style the following elements

* Edit Properties popover (currently centered and too small text)

# Points of Design Discussion

* What information should be visible on toolbar, what should be hidden?
* Should we turn the entire toolbar red for draft pages?

### Known Issues

1. When a user selects the page title, the block editing controls are enabled, though they do nothing. (Minor)

## 4.0 Release Testing

* Verify caching works (was refactored)
* Page editing - iframe is too long (1600px) but using 100% height is too short.

