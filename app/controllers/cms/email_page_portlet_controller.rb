class Cms::EmailPagePortletController < Cms::PortletController
  
  def deliver
    message = EmailMessage.new(params[:email_message])
    message.subject = @portlet.subject
    message.body = "#{params[:url]}\n\n#{message.body}"
    if message.save
      redirect_to_success_url
    else
      redirect_to_failure_url_with_errors(message.errors)
    end
  end
  
end