module Cms
  class InlineContentController < Cms::BaseController
    respond_to :js

    def update
      content = Content.find_draft(params[:content_name], params[:id])
      content.update_attributes(filtered_content)
      @page = Page.find_draft(params[:page_id])
      if (!@page.live?)
        page_status = "draft-status"
        status_label = "DRAFT"
      else
        page_status = "published-status"
        status_label = "Published"
      end
      render json: { page_status: page_status, status_label: status_label, page_title: @page.title}, layout: false
    end

    private

    def filtered_content
      ContentFilter.new.filter(params[:content])
    end
  end
end