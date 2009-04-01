class DynamicPortlet < Portlet
  
  def renderer(portlet)
    lambda do
      eval(portlet.code) unless portlet.code.blank?
      render :inline => portlet.template
    end
  end
    
end