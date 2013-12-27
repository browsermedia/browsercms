module Cms
  class TasksController < Cms::BaseController

    before_filter :load_page, :only => [:new, :create]

    def new
      @task = @page.tasks.build(:assigned_by => current_user)
    end

    def create
      @task = @page.tasks.build(task_params())
      @task.assigned_by = current_user
      if @task.save
        flash[:notice] = "Page was assigned to '#{@task.assigned_to.login}'"
        redirect_to @page.path
      else
        render :action => 'new'
      end
    end

    def complete
      if params[:task_ids]
        Task.where(["id in (?)", params[:task_ids]]).each do |t|
          if t.assigned_to == current_user
            t.mark_as_complete!
          end
        end
        flash[:notice] = "Tasks marked as complete"
        redirect_to dashboard_path
      else
        @task = Task.find(params[:id])
        if @task.assigned_to == current_user
          if @task.mark_as_complete!
            flash[:notice] = "Task was marked as complete"
          end
        else
          flash[:error] = "You cannot complete tasks that are not assigned to you"
        end
        redirect_to @task.page.path
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "No tasks were marked for completion"
      redirect_to dashboard_path
    end

    private
    def task_params
      params.require(:task).permit(Cms::Task.permitted_params)
    end

    def load_page
      @page = Page.find(params[:page_id])
    end

  end
end