class UsesHelperPortlet < Cms::Portlet

  # Mark this as 'true' to allow the portlet's template to be editable via the CMS admin UI.
  enable_template_editor false
  description "[TEST] Exists only to test helper functionality in BrowserCMS."

  def render
    page_title "A Custom Title"
  end
    
end