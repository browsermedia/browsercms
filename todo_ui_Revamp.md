## Big Tasks

* Integrate Mercury
* Do UX for the content library, admin and sitemap
* Implement implied features (Search/Notifications)

## Integrate Mercury

* Currently loading from test/dummy app. Need to ensure jquery+other libraries are loaded by the CMS engine.

### Notes

* Multiple versions of jquery being loaded breaks things.

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

* Need a * for the BrowserCMS logo
* Edit Properties popover (currently centered and too small text)
* Disabled state looks bad
* New button shouldn't be split like it is

# Points of Design Discussion

* What information should be visible on toolbar, what should be hidden?
* Should we turn the entire toolbar red for draft pages?



## 4.0 Release Testing

* Verify caching works (was refactored)
* Page editing - iframe is too long (1600px) but using 100% height is too short.
