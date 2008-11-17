class DynamicPortlet < Portlet
  
  def render
    eval(self.code)
    begin
      ERB.new(self.template).result(binding)
    rescue Exception
      CGI.escapeHTML "Could not render template: #{$!}\n"
    end      
  rescue Exception
    CGI.escapeHTML "Could not evaluate code: #{$!}\n"
  end  
  
end