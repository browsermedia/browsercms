# A portlet type that can be used to deprecate and remove old portlets.
# During migrations, change existing portlet types with this and remove the old classes.
#
# This will not appear as a selectable portlet type, but can render itself
class DeprecatedPlaceholder < Cms::Portlet

  enable_template_editor false

  def render

  end
end