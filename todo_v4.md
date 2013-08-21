Tasks:

* Database Templates:
  - Remove disk writing (no longer necessary)
  - Add migrations for existing data
* Make it easier to create controller as pages
  - I.e. a custom login form
  - Should include cms_toolbar (for free) when logged in(?)
  - DSL for mapping groups to temp users.
  - Groups should have purpose/description field. Explain who this group represents.
  - Groups should have 'external' user flag to prevent deletion.
* Multisite (for larger sites) 
* User Management[Devise?]
  - Built in 'Temp' users (store arbitrary attributes in session)
  - Forgot Password (for admins) 
  - Public login page (for non-admins)
* Marketing / Email notifications

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

