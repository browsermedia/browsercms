[#623] Refactor to use SimpleForm

* Convert the existing forms to use simple rather than our custom form code.


## Remaining Tasks:

* Need an as: :content_name for handling slugs?
* Generators should create using new format.
* Add deprecation warnings.

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

* check_box
* datetime_select

## Cleanup

## Bugs

* EmailPagePortlet doesn't actually work when you submit the form.
* Tag list does not automatically suggest tags.
