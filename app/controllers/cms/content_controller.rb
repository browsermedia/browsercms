module Cms
  class ContentController < Cms::ApplicationController
    include Cms::ContentRenderingSupport
    include Cms::Attachments::Serving

    include Cms::MobileAware
    helper MobileHelper

    skip_before_filter :redirect_to_cms_site
    before_filter :redirect_non_cms_users_to_public_site, :only => [:show, :show_page_route]
    before_filter :construct_path, :only => [:show]
    before_filter :construct_path_from_route, :only => [:show_page_route]
    before_filter :try_to_redirect, :only => [:show]
    before_filter :try_to_stream_file, :only => [:show]
    before_filter :check_access_to_page, :only => [:show, :show_page_route]
    before_filter :select_cache_directory


    # ----- Actions --------------------------------------------------------------
    def show
      if @show_toolbar && params[:show_page] != 'show'
        render_editing_frame
      else
        render_page
      end
      cache_if_eligible
    end

    def show_page_route
      @_page_route.execute(self) if @_page_route
      render_page
      cache_if_eligible
    end


    # Used by the rendering behavior
    def instance_variables_for_rendering
      instance_variables - (@initial_ivars || []) - ["@initial_ivars"]
    end

    protected

    # This will assign the value to an instance variable
    def assign(key, value)
      instance_variable_set("@#{key}", value)
    end

    private

    def render_editing_frame
      @page_title = @page.page_title
      render 'editing_frame', :layout => 'cms/page_editor'
    end

    def render_page
      prepare_connectables_for_render
      page_layout = determine_page_layout
      render :layout => page_layout, :action => 'show'
    end

    def cache_if_eligible
      cache_page if should_cache_page?
    end

    # Determine if this page is eligible for caching or not.
    def should_cache_page?
      should_cache = (using_cms_subdomains? && !logged_in? && @page.cacheable? && params[:cms_cache] != "false")
      if should_cache
        msg = "'#{request.path}' being written to cache."
      else
        msg = "'#{request.path}' not eligible for caching."
      end
      logger.info msg
      should_cache
    end

    # ----- Before Filters -------------------------------------------------------
    def construct_path
      # @paths = params[:cms_page_path] || params[:path] || []
      
      # When add_dynamic_routes is run by route_extensions.rb, path is 
      # passed in as :_path
      @path = params[:_path] || "/#{params[:path]}"
      @paths = @path.split("/")
    end

    def construct_path_from_route
      @_page_route = PageRoute.find(params[:_page_route_id])
      @path = @_page_route.page.path
      @initial_ivars = instance_variables
      eval @_page_route.code
    end

    def redirect_non_cms_users_to_public_site
      @show_toolbar = false
      if using_cms_subdomains?
        logger.debug "Using cms subdomain is enabled"
        if request_is_for_cms_subdomain?
          logger.debug "User has required a page on the cms subdomain."
          if current_user.able_to?(:edit_content, :publish_content, :administrate)
            logger.debug "User has access to cms"
            @show_toolbar = true
          else
            logger.debug "User does not have access to cms"
            redirect_to url_without_cms_domain_prefix
          end
        else
          logger.debug "User has requested a page which is not on the cms domain."
        end
      else
        logger.debug "Using cms subdomain is disabled"
        if current_user.able_to?(:edit_content, :publish_content, :administrate)
          @show_toolbar = true
        end
      end
      @show_page_toolbar = @show_toolbar
      true
    end

    def try_to_redirect
      if redirect = Redirect.find_by_from_path(@path)
        redirect_to redirect.to_path, :status => :moved_permanently
      end
    end

    # Determines if the current request is file that needs to be streamed.
    # Any URL with a . in it is considered a file.
    def is_file?
      split = request.url.split('.')
      ext = split.size > 1 ? split.last.to_s.downcase : nil
      !ext.blank?
    end

    def try_to_stream_file
      if is_file?
        @attachment = Attachment.find_live_by_file_path(request.fullpath)
        send_attachment(@attachment)
      end

    end

    def check_access_to_page
      set_page_mode
      if current_user.able_to?(:edit_content, :publish_content, :administrate)
        logger.debug "Displaying draft version of page"
        if page = Page.first(:conditions => {:path => @path})
          @page = page.as_of_draft_version
        else
          return render(:layout => 'cms/application',
                        :template => 'cms/content/no_page',
                        :status => :not_found)
        end
      else
        logger.debug "Displaying live version of page"
        @page = Page.find_live_by_path(@path)
        page_not_found unless (@page && !@page.archived?)
      end

      unless current_user.able_to_view?(@page)
        store_location
        raise Cms::Errors::AccessDenied
      end

    end

    # ----- Other Methods --------------------------------------------------------

    def page_not_found
      raise ActiveRecord::RecordNotFound.new("No page at '#{@path}'")
    end

    def set_page_mode
      @mode = @show_toolbar && current_user.able_to?(:edit_content) ? (params[:mode] || session[:page_mode] || "edit") : "view"
      session[:page_mode] = @mode
    end


  end
end
