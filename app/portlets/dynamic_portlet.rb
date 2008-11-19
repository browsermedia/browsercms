class DynamicPortlet < Portlet
  
  def renderer(portlet)
    lambda do
      eval(portlet.code)
      render :inline => portlet.template
    end
  end
    
end