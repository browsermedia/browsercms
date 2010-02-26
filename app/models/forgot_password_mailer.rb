class ForgotPasswordMailer < ActionMailer::Base

  def reset_password(link, email)
    @subject    = I18n.t("models.forgot_password_mailer.account_management")
    @body[:url] = link
    @recipients = email
    @from       = 'do_not_reply@domain.com'
    @sent_on    = Time.now
    template "cms/forgot_password_mailer/reset_password"
  end

end
