module Cms
class DashboardController < Cms::BaseController
      
  def index
    @unpublished_pages = Page.unpublished.all(:order => "updated_at desc")
    @unpublished_pages = @unpublished_pages.select { |page| cms_current_user.able_to_publish?(page) }
    @incomplete_tasks = cms_current_user.tasks.incomplete.all(
      :include => :page, 
      :order => "#{Task.table_name}.due_date desc, #{Page.table_name}.name")
  end
end
end