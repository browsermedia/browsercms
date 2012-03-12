class ContentPageController < ApplicationController

  include Cms::Acts::ContentPage
  layout 'templates/subpage'

  def index

  end

  def custom_page
    self.page_title = "My Custom Page"
  end
end
