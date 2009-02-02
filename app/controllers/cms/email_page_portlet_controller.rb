class Cms::EmailPagePortletController < Cms::PortletController
  skip_before_filter :login_required
  
  verify :method => :post, :only => :deliver

  def deliver
    message = EmailMessage.new(params[:email_message])
    message.subject = @portlet.subject
    message.body = "#{params[:url]}\n\n#{message.body}"
    if message.save
      begin
        message.deliver!
      rescue Exception => e
        logger.warn "Failed to deliever message: #{e.class.name} - #{e.message}\n#{e.backtrace}"
      end
      redirect_to_success_url
    else
      redirect_to_failure_url_with_errors(message.errors)
    end
  end
  
end