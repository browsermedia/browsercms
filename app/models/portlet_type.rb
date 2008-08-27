class PortletType < ActiveRecord::Base
  has_many :portlets
  
  def render(portlet)
    @portlet = portlet
    eval(code)
    begin
      Haml::Engine.new(template).render(self)
    rescue 
      CGI.escapeHTML "Could not render template: #{$!}\n"
    end      
  rescue
    CGI.escapeHTML "Could not evaluate code: #{$!}\n"
  end  
  
end
