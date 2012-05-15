module Cms

  module MobileAware

    include Cms::DefaultCaches

    # Looks for a mobile template if the request is mobile, falling back to the html template if it can't be found.
    #
    # @return [String] relative path/name of the layout to be rendered by a page (i.e. 'layouts/templates/default')
    def determine_page_layout
      if respond_as_mobile?
        mobile_exists = template_exists?(@page.layout_name, "layouts/mobile")
        return @page.layout(:mobile) if mobile_exists
      end
      @page.layout(:full)
    end

    # This is changing a class attribute in order to write the page cache to a different directory based on mobile vs full page request.
    # @warning - May not be thread safe?
    def select_cache_directory
      if respond_as_mobile?
        self.class.page_cache_directory = mobile_cache_directory
      else
        self.class.page_cache_directory = cms_cache_directory
      end
    end

    # Because of caching, CMS pages should only return mobile content on a separate subdomain.
    # or if a CMS editor wants to see the mobile version of the page.
    #
    # @return [Boolean] true if this request is considered 'mobile', false otherwise
    def respond_as_mobile?
      log "For mobile optimization, checking the subdomain for '#{request.domain}' is '#{request.subdomain}'."
      if params[:template] =='mobile'
        session[:mobile_mode] = true
      elsif params[:template] =='full'
        session[:mobile_mode] = false
      end

      request.subdomain == "m" || (session[:mobile_mode] == true && current_user.able_to?(:edit_content))
    end

    private

    def print_request_info
      log "*" * 20
      log "User Agent: #{request.user_agent}"
      m = "Mobile Request?: "
      if respond_as_mobile?
        m += "Yes"
      else
        m += "No"
      end
      log m
    end

    def log(m)
      logger.debug m
    end

    def banner(m)
      log "*" * 20
      log m
    end
  end

end