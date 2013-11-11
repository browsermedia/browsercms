module Cms
  class DashboardController < Cms::BaseController

    def index
      @unpublished_pages = Page.unpublished.order("updated_at desc")
      @unpublished_pages = @unpublished_pages.select { |page| current_user.able_to_publish?(page) }
      @incomplete_tasks = current_user.tasks.incomplete.
          includes(:page).
          order("#{Task.table_name}.due_date desc, #{Page.table_name}.name").
          references(:page)
    end
  end
end