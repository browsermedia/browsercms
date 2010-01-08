class EmailMessageMailer < ActionMailer::Base
  
  def email_message(message)
    @recipients = message.recipients
    @from = message.sender
    @subject = message.subject
    @body = message.body
    @content_type = message.content_type if message.content_type
  end

end
