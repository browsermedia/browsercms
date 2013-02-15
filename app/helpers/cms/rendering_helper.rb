##
# Provides specific helper methods to render content blocks and connectors.
# Split off from Cms::ApplicationController so it can be included in Cms::Acts::ContentPage
#
module Cms
  module RenderingHelper

    # Renders the content for the given field from the current content block.
    # Designed to be used in Block Templates instead of direct output of fields.
    #   Example:
    #     <pre><%= show :content %></pre>
    #   Instead of:
    #     <pre><%= @content_block.content.html_safe %></pre>
    #
    # Why bother?: This abstracts the actual variable name (makes future upgrades more robust),
    #   as well as let us mark up the content with html_safe,
    #   plus conditionally make fields editable.
    #
    # @param [Symbol] method
    # @param [Hash] options
    def show(method, options={})
      if (!logged_in?) # Need to check the current user can edit the page attached to this block too
        @content_block.send(method).html_safe
      else
        #editor_info = @content_block.editor_info(method)
        content_tag 'div',
                    id: "#{@content_block.content_block_type}-#{@content_block.id}-#{method}",
                    class: 'content-block',
                    contenteditable: true,
                    data: {
                      class: @content_block.content_block_type,
                      id: @content_block.id,
                      attribute: method

                    } do
          content = @content_block.send(method)
          content.to_s.html_safe
        end
      end

    end

    # Renders a table of attachments for a given content block.
    # This is intended as a basic view of the content, and probably won't be suitable for blocks that need to be added directly to pages.
    #
    def attachment_viewer(content)
      render :partial => 'cms/attachments/attachment_table', :locals => {:block => content, :can_delete => false}
    end

    # Determines if a user is currently editing this page
    def is_editing_page?(page)
      logged_in? && current_user.able_to_edit?(page)
    end

    def render_connector_and_connectable(connector, connectable)
      logger.debug "Rendering #{connectable} "
      if is_editing_page?(connector.page)
        #render(:partial => 'cms/pages/edit_connector', :locals => { :connector => connector, :connectable => connectable})
        render(:partial => 'cms/pages/edit_content', :locals => {:connector => connector, :connectable => connectable})
      else
        render_connectable(connectable)
      end
    end

    def render_connectable(content_block)
      if content_block
        if content_block.class.renderable?
          logger.debug "Rendering connectable #{content_block.class} ##{content_block.id} #{"v#{content_block.version}" if content_block.respond_to?(:version)}"
          content_block.perform_render(controller)
        else
          logger.warn "Connectable #{content_block.class} ##{content_block.id} is not renderable"
        end
      else
        logger.warn "Connectable is null"
      end
    rescue Exception => e
      logger.error "Error occurred while rendering #{content_block.class}##{content_block.id}: #{e.message}\n#{e.backtrace.join("\n")}"
      "ERROR: #{e.message}"
    end

    ##
    # Renders the toolbar for the CMS. All page templates need to include this or they won't be editable.
    # Typically rendered as an iframe to avoid CSS/JS conflicts.
    #
    # @param [Symbol] tab Which tab of the dashboard to highlight. Defaults to :dashboard.
    #
    def render_cms_toolbar(tab=:dashboard)
      render :partial => 'layouts/cms_toolbar', :locals => {:tab => tab}
    end
  end
end