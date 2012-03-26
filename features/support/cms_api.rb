module Cms
  module WebApi

    # Log in to the CMS admin.
    def login_as(username, password)
      visit '/cms/login'
      fill_in 'login', :with => username
      fill_in 'password', :with => password
      click_button 'LOGIN'
    end
  end
end
World(Cms::WebApi)