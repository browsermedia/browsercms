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

    # For inspecting content of a page. Will follow the 'editing' frame if it exists.
    # Works around lack of within_frame for rack test.
    #
    # WARNING: Does not 'return' to previous page, so don't expect tests like this to work:
    #   <pre>
    #   within_content_frame do
    #     assert some_content_exists
    #   end
    #   assert something_is_on_toolbar
    #   </pre>
    def within_content_frame
      if page_has_editor_iframe?
        visit find(editor_iframe_selector)['src']
      end
      yield
    end

    def page_has_editor_iframe?
      page.has_selector?(editor_iframe_selector)
    end

    def editor_iframe_selector
      "iframe[name='page_content']"
    end
  end
end
World(Cms::WebApi)