class Cms::DashboardController < Cms::BaseController
      
  def index
    @draft_pages = Page.draft.all(:order => "updated_at desc")
  end
end