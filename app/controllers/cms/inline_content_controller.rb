module Cms
  class InlineContentController < Cms::BaseController
    respond_to :js

    def update
      content_block = Content.find_draft(params[:content_name], params[:id])
      content_block.update_attributes(filtered_content(content_block))
      @page = Page.find_draft(params[:page_id].to_i)
      if (!@page.live?)
        page_status = "draft"
        status_label = "This page is in draft status"
      else
        page_status = "published"
        status_label = "Published"
      end

      # After a page update, all the connector ids can change. So we need to send
      # the new move up/down/remove paths to client so they will work after an inline update.
      routes = []
      if params[:container]
        connectors = @page.current_connectors(params[:container].to_sym)
        connectors.each do |c|
          routes << {
              move_up: cms.move_up_connector_path(c, format: :json),
              move_down: cms.move_down_connector_path(c, format: :json),
              remove: cms.connector_path(c, format: :json)
          }
        end
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

    def filtered_content(content_block)
      ContentFilter.new.filter(content_params(content_block))
    end

    def content_params(content)
      params.require(:content).permit(content.class.permitted_params)
    end
  end
end