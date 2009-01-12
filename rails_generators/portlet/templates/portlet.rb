class <%= class_name %> < Portlet
    
  def renderer(portlet)
    lambda do
      locals = {:portlet => portlet}
      # Your Code Goes Here
      render :partial => portlet.class.partial, :locals => locals
    end
  end
    
end