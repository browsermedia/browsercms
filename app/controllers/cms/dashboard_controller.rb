class Cms::DashboardController < Cms::BaseController
      
  def index
    @unpublished_pages = Page.unpublished.all(:order => "updated_at desc")
    @unpublished_pages = @unpublished_pages.select { |page| current_user.able_to_publish?(page) }
    @incomplete_tasks = current_user.tasks.incomplete.all(
      :include => :page, 
      :order => "#{Cms::Task.table_name}.due_date desc, #{Cms::Page.table_name}.name")
  end
end
