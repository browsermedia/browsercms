module Cms
  class PageComponent
    extend ActiveModel::Naming

    attr_accessor :page_id, :page_title

    def initialize(page_id, params)
      params = HashWithIndifferentAccess.new(params)
      self.page_title = params[:page_title]
      self.page_id = page_id
    end


    # Save the change to the underlying page (and its content)
    def save
      @page = Page.find(@page_id)
      @page.title = page_title[:value]
      @page.save
    end
  end
end