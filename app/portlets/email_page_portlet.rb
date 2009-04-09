class EmailPagePortlet < Portlet
  
  def render
    pmap = flash[instance_name] || params
    @email_message = EmailMessage.new pmap[:email_message]
    @email_message.errors.add_from_hash flash["#{instance_name}_errors"]
    @url = pmap[:url] || request.referer
  end
  
end