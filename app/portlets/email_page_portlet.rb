class EmailPagePortlet < Portlet
  
  def self.default_template
    template = <<-HTML
<div class="email-page-portlet">
  <% form_for email_message, {:url => "/cms/email_page_portlet/deliver/#{portlet.id}"} do |f| %>
    <%= hidden_field_tag :url, url %> 
    <%= f.error_messages %>
    <p>
      <%= f.label :recipients %>
      <%= f.text_field :recipients %>
    </p>
    <p>
      <%= f.label :body %>
      <%= f.text_area :body, :size => "50x3" %>
    </p>
    <p>
      <%= submit_tag "Send Email" %>
    </p>
  <% end %>
</div> 
    HTML
    template.chomp
  end  

  def renderer(portlet)
    lambda do
      pmap = flash[portlet.instance_name] || params
      locals = {}
      locals[:portlet] = portlet
      locals[:email_message] = EmailMessage.new pmap[:email_message]
      locals[:url] = pmap[:url] || request.referer
      render :inline => portlet.template, :locals => locals
    end
  end  
  
end