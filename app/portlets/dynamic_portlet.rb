class DynamicPortlet < Portlet

  def render
    eval @portlet.code
  end

end