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

    def most_recently_created_page
      Cms::Page.order("created_at DESC").first
    end
  end
end
World(Cms::WebApi)