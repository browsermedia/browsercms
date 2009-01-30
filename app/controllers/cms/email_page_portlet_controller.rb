class Cms::EmailPagePortletController < Cms::PortletController
  skip_before_filter :login_required
  
  verify :method => :post, :only => :deliver

  redirect_action "deliver" do
    message = EmailMessage.new(params[:email_message])
    message.subject = @portlet.subject
    message.body = "#{params[:url]}\n\n#{message.body}"
    message.save!
  end
  
end