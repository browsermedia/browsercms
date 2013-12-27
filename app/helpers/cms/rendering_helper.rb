##
# Provides specific helper methods to render content blocks and connectors.
# Split off from Cms::ApplicationController so it can be included in Cms::Acts::ContentPage
#
module Cms
  module RenderingHelper

    def page_content_iframe(path)
      content_tag "iframe", "" , src: path, id: 'page_content', frameborder: 0, width: '100%', height: '80%'
      #<iframe id="page_content" src="<%= url_for engine_aware_path(@block, :inline) %>" frameborder="0" width="100%" height="80%"></iframe>

    end
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
      if (!is_current_user_able_to_edit_this_content?(@content_block)) # Need to check the current user can edit the page attached to this block too
        value = @content_block.send(method)
        value.respond_to?(:html_safe) ? value.html_safe : value
      else
        content_tag 'div',
                    id: random_unique_identifier(),
                    class: 'content-block',
                    contenteditable: true,
                    data: {
                      content_name: @content_block.content_name,
                      id: @content_block.id,
                      attribute: method,
                      page_id: @page.id

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

    # Determines if the current user can edit and is currently editing this content.
    def is_current_user_able_to_edit_this_content?(content)
      content && logged_in? && edit_mode? && current_user.able_to_edit?(content)
    end

    # @deprecated
    alias :is_editing_page? :is_current_user_able_to_edit_this_content?

    def render_connector_and_connectable(connector, connectable)
      if is_current_user_able_to_edit_this_content?(connector.page)
        render(:partial => 'cms/pages/edit_content', :locals => {:connector => connector, :connectable => connectable})
      else
        render_connectable(connectable)
      end
    end

    def render_connectable(content_block)
      if content_block
        if content_block.class.renderable?
          Rails.logger.debug "Rendering connectable #{content_block.class} ##{content_block.id} #{"v#{content_block.version}" if content_block.respond_to?(:version)}"
          content_block.perform_render(controller)
        else
          Rails.logger.warn "Connectable #{content_block.class} ##{content_block.id} is not renderable"
        end
      else
        Rails.logger.warn "Connectable is null"
      end
    rescue Exception => e
      Rails.logger.error "Error occurred while rendering #{content_block.class}##{content_block.id}: #{e.message}\n#{e.backtrace.join("\n")}"
      "ERROR: #{e.message}"
    end

    # Some content doesn't have inline editing, so we need to conditionally show move up/down/remove buttons on the page
    def content_supports_inline_editing?(connector)
      content = connector.connectable
      content.supports_inline_editing?
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

    private

    # Each block needs a unique id on the page so CKeditor can attach to it. Doesn't matter what it is though.
    # This ensure that if the same block is add twice, it will still work.
    def random_unique_identifier
      SecureRandom.urlsafe_base64
    end
  end
end