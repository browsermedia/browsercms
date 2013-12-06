# Shows a 'Login' form.
#
# This portlet should not typically necessary in CMS 4.0 or later since there is a built
# in /login route built in.
class LoginPortlet < Cms::Portlet

  enable_template_editor false
  description "Display a login form (Consider using /login instead)."

  def render
  end
    
end
