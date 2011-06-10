require 'test_helper'

class Cms::TasksControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    @admin = login_as_cms_admin

    @task = Factory(:task, :assigned_to=>@admin)
  end

  def test_complete_task
    task = Cms::Task.find_by_id_and_assigned_to_id(@task.id, @admin.id)
    assert_instance_of Cms::Task, task, "This test depends on there being a task to complete"
    assert !task.completed?

    put :complete, :id => @task.id
    assert_response :redirect
    assert_redirected_to task.page.path
    assert_equal "Task was marked as complete", flash[:notice]

    task.reload
    assert task.completed?
  end


  def test_complete_multiple_tasks
    @task2 = Factory(:task, :assigned_to=>@admin)
    ids = [@task.id, @task2.id]
    tasks = Cms::Task.find(:all, :conditions => ["assigned_to_id = ?", @admin.id])
    assert_equal 2, tasks.length, "This test depends on there being 2 tasks to complete"
    assert !tasks.detect {|t| t.completed?}

    # should update all tasks in the ids list
    put :complete, :task_ids => ids
    assert_response :redirect
    assert_redirected_to cms_dashboard_path
    assert_equal "Tasks marked as complete", flash[:notice]

    tasks.each do |t|
      t.reload
      assert t.completed?
    end

    # if empty list is passed, should gracefully claim to have completed them all
    put :complete, :task_ids => []
    assert_response :redirect
    assert_redirected_to cms_dashboard_path
    assert_equal "Tasks marked as complete", flash[:notice]
  end

  def test_complete_no_tasks
    put :complete, :task_ids => nil
    assert_response :redirect
    assert_redirected_to cms_dashboard_path
    assert_equal "No tasks were marked for completion", flash[:error]
  end

end
