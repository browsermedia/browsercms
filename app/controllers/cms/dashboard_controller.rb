class Cms::DashboardController < Cms::BaseController
      
  def index
    @unpublished_pages = Page.unpublished.all(:order => "updated_at desc")
    @incomplete_tasks = current_user.tasks.incomplete.all(
      :include => :page, 
      :order => "tasks.due_date desc, pages.name")
  end
end