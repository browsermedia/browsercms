module Cms
  class InlineContentController < Cms::BaseController
    respond_to :js

    def update
      content = Content.find_draft(params[:content_name], params[:id])
      content.update_attributes(filtered_content)
      @page = Page.find_draft(params[:page_id].to_i)
      if (!@page.live?)
        page_status = "draft-status"
        status_label = "DRAFT"
      else
        page_status = "published-status"
        status_label = "Published"
      end

      # After a page update, all the connector ids change. So we need to send
      # the new move up/down/remove paths to client so they will work after an inline update.
      connectors = @page.current_connectors(params[:container].to_sym)
      routes = []
      connectors.each do |c|
        routes << {
            move_up: cms.move_up_connector_path(c, format: :json),
            move_down: cms.move_down_connector_path(c, format: :json),
            remove: cms.connector_path(c, format: :json)
        }
      end
      results = {
          page_status: page_status,
          status_label: status_label,
          page_title: @page.title,
          container: params[:container].to_s,
          routes: routes
      }
      render json: results, layout: false
    end

    private

    def filtered_content
      ContentFilter.new.filter(params[:content])
    end
  end
end