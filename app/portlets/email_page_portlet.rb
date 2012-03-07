class EmailPagePortlet < Cms::Portlet

  def render
    pmap = flash[instance_name] || params
    @email_message = Cms::EmailMessage.new pmap[:email_message]
    @email_message.errors.add_from_hash flash["#{instance_name}_errors"]
    @email_page_portlet_url = pmap[:email_page_portlet_url] || request.url
  end


  #----- Handlers --------------------------------------------------------------
  def deliver
    message = Cms::EmailMessage.new(params[:email_message])
    message.subject = self.subject
    message.body = "#{params[:email_page_portlet_url]}\n\n#{message.body}"    
    if message.save
      url_for_success
    else
      store_params_in_flash
      store_errors_in_flash(message.errors)
      url_for_failure
    end
  end
  
end
