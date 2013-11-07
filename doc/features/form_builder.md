# Form Builder

Allow content editors to create new form via the interface.

## Remain issues/features

* [MINOR] Unique icon for forms (i.e. custom) for sitemap
* [Improvement] Captcha?
* [FEATURE] Allow sorting/reporting.
* [BUG] Preview for dropdowns is inaccurate (doesn't change after updates). To fix, would need to refactor to have HTML returned rather than JSON.
* [BUG] 500 errors when posting forms within CMS shows errors within double nested toolbar.
* [Improvement] Default Forms just uses bootstrap, which is probably not a valid option. Need a way to pare it down to avoid changing styles for existing designes.
* [BUG] After adding a field, it clears but does not correctly show the 'blank' value.
* [BUG] Addressable content types (product, forms, etc) do not/cannot appear in menus without manually creating a link.

## Documentation

## Forms

* Can notify staff when a form is submitted.
* Email mailbot can be configured in application.rb

### Configuration

In config/application.rb, to change which CSS stylesheet is applied to Form pages, update the following:

```
 # Default is 'cms/default-forms'
 config.cms.form_builder_css = 'my-forms' # Returns /assets/my-forms.css
```

# New Namespacing

When upgrading, Content Models should be moved under application namespace. Basis steps:

    Custom models should have the following added to them:
        Create a directory in the project named app/models/cms
        Move any Content Blocks into that directory.
        Rename from Widget to *Cms::*Widget
        Add self.table_name = :widgets (or migrate the table from widgets to cms_widgets)
