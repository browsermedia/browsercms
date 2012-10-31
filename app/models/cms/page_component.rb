module Cms
  class PageComponent
    extend ActiveModel::Naming

    attr_accessor :page_id, :page_title, :blocks

    def initialize(page_id, params)
      params = HashWithIndifferentAccess.new(params)
      self.page_title = params[:page_title]
      self.blocks = params[:blocks]
      self.page_id = page_id
    end


    # Save the change to the underlying page (and its content)
    def save
      @page = Page.find(@page_id)
      @page.title = page_title[:value]
      blocks.each do |block_type|
        content_block_class = block_type[0]
        content_ids = block_type[1].keys

        content_ids.each do |block_id|
          block = content_block_class.constantize.find(block_id)

          # Only really handles HtmlBlock right now
          block.content = block_type[1][block_id][:value]
          block.save!
        end
      end
      @page.save
    end
  end
end