class DynamicPortlet < Portlet

  def render
    eval @portlet.code
  end

  def inline_options
    {:inline => @portlet.template}
  end

end