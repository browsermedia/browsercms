Tasks:

Testing:

ruby -Ilib -Itest test/unit/models/content_type_mini_test.rb --name=/available_by_module/

* Make it easier to create controller as pages
  - I.e. a custom login form
  - Should include cms_toolbar (for free) when logged in(?)
  - DSL for mapping groups to temp users.
  - Groups should have purpose/description field. Explain who this group represents.
  - Groups should have 'external' user flag to prevent deletion.
* User Management[Devise?]
  - Built in 'Temp' users (store arbitrary attributes in session)
  - Forgot Password (for admins) 
  - Public login page (for non-admins)
* Marketing / Email notifications

## UI Merge Items
* page_editor.css/page_content_editing.css shouldn't have been deleted during the bootstrap UI merge.
* Can't edit the root section

## Admin Menu
* Enforce link security for menus


### Known Issues

1. When a user selects the page title, the block editing controls are enabled, though they do nothing. (Minor)

## 4.0 Release Testing

* Verify caching works (was refactored)
* Page editing - iframe is too long (1600px) but using 100% height is too short.


