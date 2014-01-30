[#623] Refactor CMS forms to use SimpleForm

Converted all the internal forms to use SimpleForm rather than our own custom form builder. This provides better consistency with bootstrap forms, as well as well tested API for defining new form inputs. This will primarily affect developers when they create content blocks. New content will be generated using simple_form syntax like so:

<%= f.input :photo, as: :file_picker %>

rather than the older syntax that looks like this:

<%= f.cms_file_field :photo %>

The old form_builder methods like cms_text_field and cms_file_field have been deprecated and will generate warnings when used. These methods are scheduled for removal in BrowserCMS 4.1. It's recommended that custom content blocks be upgraded to use the new syntax when feasible. The deprecation warnings should provide some guideance, but also look at simple_forms documentation http://simple-form.plataformatec.com.br for help.

## Available Input Types

All of the existing simple_form input mappings are available. See http://simple-form.plataformatec.com.br/#mappings-inputs-available for the reference. BrowserCMS adds some additional input types for specific CMS features.

|# Mapping | Input | Purpose/column type #|
| file_picker | File Upload | A single attachment with section/path selectors |
| cms_text_area | text area | Like :text but with a :default |
| cms_text_field | text field | Like :string with optional path generator (for addressable content types)|
| date_picker | jquery date select | date   |
| path | text field | A slug/path for addressable content (works with cms_text_field to automatically generate names)   |
| template_editor | text area | For editing templates via ERB or other permitted template languages. |
| text_editor | WYSIWYG editor | For editing HTML content (has toggle to use a text area |
| attachments | Multiple File Uploads | Unlimited # of attachments. |
| tag_list| text field | has_many with :tags |

### Usage

Here are some examples showing how to use the CMS specific inputs.

```
<%= f.input :name %>
```

Generates the 'name' field as a text field.

```
<%= f.input :expires_on, as: :date_picker %>
```

Renders a text_field that can be left blank or have a date entered into it as text. Clicking on it will bring up a JQuery Date Picker to select the date.

```
<%= f.input :template, as: :template_editor %>
```

Renders a template editor (if the content block has enabled template editing). The default template body for the model will be used when creating a new record.


### Usage Exceptions

Several of the input types above are not used directly, but rather via methods like this that hide some of their complexity:

```
<%= f.cms_attachment_manager %>
<%= f.cms_tag_list %>
```


