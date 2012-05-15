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
      render_page_with_caching
    end

    def show_page_route
      render_page_with_caching
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

    # This is the method all actions delegate to
    # check_access_to_page will also call this directly
    # if caching is not enabled
    def render_page
      logger.warn "Render page (id: #{@page.id})"
      @_page_route.execute(self) if @_page_route
      prepare_connectables_for_render
      page_layout = determine_page_layout
      render :layout => page_layout, :action => 'show'
    end

    def render_page_with_caching
      render_page
      cache_page if should_write_to_page_cache?
    end

    # ----- Before Filters -------------------------------------------------------
    def construct_path
      # @paths = params[:cms_page_path] || params[:path] || []
      @path = "/#{params[:path]}"
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

      # Doing this so if you are logged in, you never see the cached page
      # We are calling render_page just like the show action does
      # But since we do it from a before filter, the page doesn't get cached
      if logged_in?
        logger.info "Not Caching, user is logged in"
        render_page
      elsif !@page.cacheable?
        logger.info "Not Caching, page cachable is false"
        render_page
      elsif params[:cms_cache] == "false"
        logger.info "Not Caching, cms_cache is false"
        render_page
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
