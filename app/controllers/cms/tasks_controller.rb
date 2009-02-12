class Cms::TasksController < Cms::BaseController
  
  before_filter :set_toolbar_tab
  before_filter :load_page, :only => [:new, :create]
  
  def new
    @task = @page.tasks.build(:assigned_by => current_user)
  end
  
  def create
    @task = @page.tasks.build(params[:tasks])
    @task.assigned_by = current_user
    if @task.save
      flash[:notice] = "Page was assigned to '#{@task.login}'"
      redirect_to @page.path
    else
      render :action => 'new'
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