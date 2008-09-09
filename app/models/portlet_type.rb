class PortletType < ActiveRecord::Base
  has_many :portlets
  
  def render(portlet)
    @portlet = portlet
    eval(code)
    begin
      ERB.new(template).result(binding)
    rescue Exception
      CGI.escapeHTML "Could not render template: #{$!}\n"
    end      
  rescue Exception
    CGI.escapeHTML "Could not evaluate code: #{$!}\n"
  end  
  
end
