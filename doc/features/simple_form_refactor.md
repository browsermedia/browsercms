Refactor to use SimpleForm

* Convert the existing forms to use simple rather than our custom form code.

## Steps

1. Convert a simple form (New User)

10. Move all the manual initializers in dummy into the engine.
10. Ensure we don't conflict with existing simple_form implementations

## Widgets to Replace

* DatePicker - Need to build a component to handle jquery date pickers (with empty form fields)
    * users/_user_fields -> Expiration Date