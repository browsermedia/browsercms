class DynamicPortlet < Cms::Portlet

  def render
    eval(@portlet.code) unless @portlet.code.blank?
  end

end
