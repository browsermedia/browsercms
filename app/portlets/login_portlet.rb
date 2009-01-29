class LoginPortlet < Portlet
  
  def self.default_template
    template = <<-HTML
<div class="login-portlet">
  <div class="error"><%= flash[:login_error] %></div>
  <% form_tag "/cms/login" do %>
    <%= hidden_field_tag :success_url, portlet.success_url %>
    <%= hidden_field_tag :failure_url, portlet.failure_url %>    
    <p>
      <%= label_tag :login %>
      <%= text_field_tag :login, login %>
    </p>
    <p>
      <%= label_tag :password %>
      <%= password_field_tag :password %>
    </p>
    <p>
      <%= label_tag :remember_me %>
      <%= check_box_tag :remember_me, '1', remember_me %>
    </p>
    <p>
      <%= submit_tag "Login" %>
    </p>
  <% end %>
</div> 
    HTML
    template.chomp
  end  
  
  def renderer(portlet)
    lambda do
      render :inline => portlet.template, :locals => {:portlet => portlet, :login => params[:login], :remember_me => params[:remember_me]}
    end
  end
    
end