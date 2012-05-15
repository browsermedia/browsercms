##
# Provides specific helper methods to render content blocks and connectors.
# Split off from Cms::ApplicationController so it can be included in Cms::Acts::ContentPage
#
module Cms
  module RenderingHelper

    # Renders a table of attachments for a given content block.
    # This is intended as a basic view of the content, and probably won't be suitable for blocks that need to be added directly to pages.
    #
    def attachment_viewer(content)
      render :partial => 'cms/attachments/attachment_table', :locals => { :block => content, :can_delete => false }
    end

    def render_connector_and_connectable(connector, connectable)
      logger.debug "Rendering #{connectable} "
      if logged_in? && @mode == "edit" && current_user.able_to_edit?(connector.page)
        render(:partial => 'cms/pages/edit_connector', :locals => { :connector => connector, :connectable => connectable})
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