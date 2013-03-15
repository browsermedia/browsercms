module Cms
  class InlineContentController < Cms::BaseController
    respond_to :js

    def update
      content = Content.find_draft(params[:content_name], params[:id])

      content.update_attributes(filtered_content)
      @page = Page.find_draft(params[:page_id])
      if (!@page.live?)
        @page_status = "draft-status"
        @remove_class = "published-status"
        @status_label = "DRAFT"
        @enable_publish = true
      else
        @page_status = "published-status"
        @remove_class = "draft-status"
        @status_label = "Published"
        @enable_publish = false
      end
      render layout: false
    end

    private

    def filtered_content
      ContentFilter.new.filter(params[:content])
    end
  end
end