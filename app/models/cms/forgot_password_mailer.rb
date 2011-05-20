module Cms
  class ForgotPasswordMailer < ActionMailer::Base

    def reset_password(link, email)
      @subject = "Account Management"
      @body[:url] = link
      @recipients = email
      @from = 'do_not_reply@domain.com'
      @sent_on = Time.now
      template "cms/forgot_password_mailer/reset_password"
    end

  end
end