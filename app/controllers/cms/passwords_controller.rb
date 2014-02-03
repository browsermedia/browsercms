module Cms
  class PasswordsController < Devise::PasswordsController
    include Cms::AdminController
    layout 'cms/application'

    def new
      use_page_title('Forgot Password')
      super
    end

    def create
      use_page_title('Forgot Password')
      super
    end

    def edit
      use_page_title('Change Password')
      super
    end

  end
end