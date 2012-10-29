module Cms
  module WebApi

    attr_accessor :current_user

    # Log in to the CMS admin.
    def login_as(username, password)
      visit '/cms/login'
      fill_in 'login', :with => username
      fill_in 'password', :with => password
      click_button 'LOGIN'
    end

    def logout
      visit '/cms/logout'
    end

  end
end
World(Cms::WebApi)