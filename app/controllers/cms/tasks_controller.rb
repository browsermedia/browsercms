class Cms::TasksController < Cms::BaseController
  
  before_filter :set_toolbar_tab
  before_filter :load_page, :only => [:new, :create]
  
  def new
    @task = @page.tasks.build(:assigned_by => current_user)
  end
  
  def create
    @task = @page.tasks.build(params[:task])
    @task.assigned_by = current_user
    if @task.save
      flash[:notice] = I18n.t("controllers.tasks.created", :user => @task.assigned_to.login)
      redirect_to @page.path
    else
      render :action => 'new'
    end
  end
  
  def complete
    if params[:task_ids]
      Task.all(:conditions => ["id in (?)", params[:task_ids]]).each do |t|
        if t.assigned_to == current_user
          t.mark_as_complete!
        end
      end
      flash[:notice] = I18n.t("controllers.tasks.completed_multiple")
      redirect_to cms_dashboard_path
    else
      @task = Task.find(params[:id])
      if @task.assigned_to == current_user
        if @task.mark_as_complete!
          flash[:notice] = I18n.t("controllers.tasks.completed_multiple")
        end
      else
        flash[:error] = I18n.t("controllers.tasks.cannot_complete")
      end
      redirect_to @task.page.path
    end
  end
  
  private
    def load_page
      @page = Page.find(params[:page_id])
    end
  
    def set_toolbar_tab
      @toolbar_tab = :sitemap
    end  
  
end