module Cms
  module WebApi

    attr_accessor :current_user

    # Log in to the CMS admin.
    def login_as(username, password, path=cms.login_path)
      logout
      visit path
      fill_in 'Login', :with => username
      fill_in 'Password', :with => password
      click_button 'Sign in'
    end

    def logout
      visit cms.logout_path
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
      "iframe[id='page_content']"
    end

    def top_form_buttons
      find(".top-buttons")
    end

    def asset_selector_button
      find("button[data-purpose=subheader]")
    end

    def click_save_button
      top_form_buttons.click_on('Save')
    end

    def click_publish_button
      top_form_buttons.click_on('Publish')
    end

    def click_user_search
      click_on 'user_search_submit'
    end
  end
end
World(Cms::WebApi)