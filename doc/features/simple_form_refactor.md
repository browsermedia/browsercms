[#623] Refactor to use SimpleForm

* Convert the existing forms to use simple rather than our custom form code.


Current: Make sure switching between group types works.

## Steps

1. Replace all existing forms for non-block code
2. Replace block code
3. Make sure old widgets are deprecated but still work
4. Add new widgets for things like section selectors, etc.
5. Document new widgets on developer manual.
6. Update generators to use new simple form controls.

10. Move all the manual initializers in dummy into the engine.
10. Ensure we don't conflict with existing simple_form implementations

## Widgets to Replace


## Cleanup


* Deprecate and remove date_picker html code

## Bugs

* Tag list does not automatically suggest tags.


cucumber features/content_blocks/form_controls.feature:20 # Scenario: Multiple Individual Attachments
cucumber features/content_blocks/manage_custom_blocks.feature:26 # Scenario: Create a new block
cucumber features/portlets/email_friend_portlet.feature:8 # Scenario: Add New Portlet