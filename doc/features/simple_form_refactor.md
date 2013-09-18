[#623] Refactor to use SimpleForm

* Convert the existing forms to use simple rather than our custom form code.


Current: Make sure switching between group types works.

## Steps

1. Replace all existing forms for non-block code
2. Replace block code
3. Make sure old widgets are deprecated but still work
4. Add new widgets for things like section selectors, etc.
5. Document new widgets on developer manual.

10. Move all the manual initializers in dummy into the engine.
10. Ensure we don't conflict with existing simple_form implementations

## Widgets to Replace

## Cleanup


* Deprecate and remove date_picker html code
* Deprecate tag_list and remove it.

## Bugs

* Tag list does not automatically suggest tags.