module ForgotPasswordPortletHelper

  # Acts like this is Cms::Sites::PasswordsController
  def controller_name
    'passwords'
  end

  include Cms::Sites::DeviseShimHelper
end