module Cms
  class EmailMessageMailer < ActionMailer::Base


    def email_message(message)
      email = {:to=>message.recipients, :from=>message.sender, :subject => message.subject, :body =>message.body}
      email[:content_type]  = message.content_type if message.content_type
      mail email
    end

  end
end