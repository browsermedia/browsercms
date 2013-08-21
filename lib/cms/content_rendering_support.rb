require 'cms/error_handling'
#
# This module can be added to Controllers to provide support for rendering CMS content pages.
#
module Cms
  module ContentRenderingSupport

    def self.included(base)
      base.send :include, Cms::ErrorHandling
      base.rescue_from Exception, :with => :handle_server_error_on_page
      base.rescue_from ActiveRecord::RecordNotFound, :with => :handle_not_found_on_page
      base.rescue_from Cms::Errors::ContentNotFound, :with => :handle_not_found_on_page
      base.rescue_from Cms::Errors::DraftNotFound, :with => :handle_draft_not_found
      base.rescue_from Cms::Errors::AccessDenied, :with => :handle_access_denied_on_page

    end

    def handle_draft_not_found(exception)
      logger.warn "Draft Content Not Found"
      render(:layout => 'cms/application',
             :template => 'cms/content/no_page',
             :status => :not_found)
    end

    def handle_not_found_on_page(exception)
      logger.warn "Resource not found: Returning the 404 page."
      handle_error_with_cms_page(Cms::ErrorPages::NOT_FOUND_PATH, exception, :not_found)
    end

    def handle_access_denied_on_page(exception)
      logger.warn "Access denied for user '#{current_user.login}': Returning the 403 page."
      handle_error_with_cms_page(Cms::ErrorPages::FORBIDDEN_PATH, exception, :forbidden)
    end

    def handle_server_error_on_page(exception)
      logger.error "An Unexpected exception occurred: #{exception.message}\n"
      logger.error "#{exception.backtrace.join("\n")}\n"
      handle_error_with_cms_page(Cms::ErrorPages::SERVER_ERROR_PATH, exception, :internal_server_error)
    end

    private

    # This is the method all error handlers delegate to
    def handle_error_with_cms_page(error_page_path, exception, status, options={})

      # If we are in the CMS, we just want to show the exception
      if perform_caching
        return handle_server_error(exception, status) if cms_site?
      else
        return handle_server_error(exception, status) if current_user.able_to?(:edit_content, :publish_content)
      end

      # We must be showing the page outside of the CMS
      # So we will show the error page
      if @page = Cms::Page.find_live_by_path(error_page_path)
        logger.debug "Rendering Error Page: #{@page.inspect}"
        @mode = "view"
        @show_page_toolbar = false

        # copy new instance variables to the template
        %w[page mode show_page_toolbar].each do |v|
          @template.instance_variable_set("@#{v}", instance_variable_get("@#{v}"))
        end

        # clear out any content already captured
        # by previous attempts to render the page within this request
        @template.instance_variables.select { |v| v =~ /@content_for_/ }.each do |v|
          @template.instance_variable_set("#{v}", nil)
        end

        prepare_connectables_for_render

        # The error pages are ALWAYS html since they are managed by the CMS as normal pages.
        # So .gif or .jpg requests that throw errors will return html rather than a format warning.
        render :layout => @page.layout, :template => 'cms/content/show', :status => status, :formats => [:html]
      else
        handle_server_error(exception, status)
      end
    end

    # If any of the page's connectables (portlets, etc) are renderable, they may have a render method
    # which does "controller" stuff, so we need to get that run before rendering the page.
    def prepare_connectables_for_render
      @_connectors = @page.current_connectors
      @_connectables = @page.contents

      unless (logged_in? && current_user.able_to?(:administrate, :edit_content, :publish_content))
        worst_exception = nil
        @_connectables.each do |c|
          begin
            c.prepare_to_render(self)
          rescue
            logger.debug "THROWN EXCEPTION by connectable #{c}: #{$!}"
            case $!
              when ActiveRecord::RecordNotFound
                raise
              when Cms::Errors::AccessDenied
                worst_exception = $!
              else
                c.render_exception = $!
            end
          end
        end
        raise worst_exception if worst_exception
      end
    end

  end
end