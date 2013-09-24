[#623] Refactor to use SimpleForm

* Convert the existing forms to use simple rather than our custom form code.


## Remaining Tasks:

* Move all the manual initializers in dummy into the engine.
* Write documentation

## Steps

10. Move all the manual initializers in dummy into the engine.
10. Ensure we don't conflict with existing simple_form implementations


## Upgrade/Documentation notes

* For content_blocks that want to be addressable, they need as: :cms_text_field rather than the default.
* Docs: Provide reference for content blocks, link to simple form docs as well as provide our specific field types.

## Bugs

* Tag list does not automatically suggest tags.
