# Shows a 'Forgot Password' form.
#
# This portlet is not typically necessary in CMS 4.0 or later since there is a built
# in /forgot-password route built in. In previous versions this portlet would have worked with a page that handled
# the reset password functionality.
#
class ForgotPasswordPortlet < Cms::Portlet

  enable_template_editor false
  description "Displays the forgot password form. (Consider using /forgot-password instead of this)"

  # Just shows the core CMS forgot password form.
  def render
  end
end
