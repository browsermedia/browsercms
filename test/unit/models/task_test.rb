require 'test_helper'

module Cms
  class TaskTest < ActiveSupport::TestCase
    def setup
      super
      @editor_a = create(:cms_admin)
      @editor_b = create(:cms_admin)
      @non_editor = create(:user, :login => "non_editor", :email => "non_editor@example.com")
      @page = create(:page, :name => "Task Test", :path => "/task_test")
      @page2 = create(:page, :name => "Task Test 2", :path => "/task_test_2")
    end
  end

  class CreateTaskTest < TaskTest

    def test_create_task
      assert_that_you_can_assign_a_task_to_yourself
      assert_that_an_assigned_by_user_that_is_an_editor_is_required
      assert_that_an_assigned_to_user_that_is_an_editor_is_required
      assert_that_a_page_is_required

      create_the_task!
      create_the_second_task!

      assert !@task.completed?
      assert(@task.due_date < Time.now)
      assert_equal "Howdy!", @task.comment

      assert_that_the_page_is_assigned_to_the_assigned_to_user
      assert_that_the_task_is_added_to_the_users_incomplete_tasks
    end

    test "Assign task sends email" do
      Rails.configuration.cms.expects(:site_domain).returns("www.browsercms.org").at_least_once

      create_the_task!

      email = Cms::EmailMessage.order('id asc').first
      assert_equal Cms::EmailMessage.mailbot_address, email.sender
      assert_equal @editor_b.email, email.recipients
      assert_equal "Page '#{@page.name}' has been assigned to you", email.subject
      assert_equal "http://cms.browsercms.org#{@page.path}\n\n#{@task.comment}", email.body
    end

    test "An email is sent when a task is created" do
      create_the_task!

      assert_equal 1, ActionMailer::Base.deliveries.size
    end

    protected

    def assert_that_you_can_assign_a_task_to_yourself
      assert_valid build(:task, :assigned_by => @editor_a, :assigned_to => @editor_a)
    end

    def assert_that_an_assigned_by_user_that_is_an_editor_is_required
      task = build(:task, :assigned_by => nil, :assigned_to => @editor_a)
      assert_not_valid task
      assert_has_error_on task, :assigned_by_id, "is required"

      task = build(:task, :assigned_by => @non_editor, :assigned_to => @editor_a)
      assert_not_valid task
      assert_has_error_on task, :assigned_by_id, Cms::Task::CANT_ASSIGN_MESSAGE
    end

    def assert_that_an_assigned_to_user_that_is_an_editor_is_required
      task = build(:task, :assigned_by => @editor_a, :assigned_to => nil)
      assert_not_valid task
      assert_has_error_on task, :assigned_to_id, "is required"

      task = build(:task, :assigned_by => @editor_a, :assigned_to => @non_editor)
      assert_not_valid task
      assert_has_error_on task, :assigned_to_id, Cms::Task::CANT_BE_ASSIGNED_MESSAGE
    end

    def assert_that_a_page_is_required
      task = build(:task, :page => nil)
      assert_not_valid task
      assert_has_error_on task, :page_id, "is required"
    end

    def create_the_task!
      @task = Cms::Task.create!(
          :assigned_by => @editor_a,
          :assigned_to => @editor_b,
          :due_date => 5.minutes.ago,
          :comment => "Howdy!",
          :page => @page)
    end

    def create_the_second_task!
      @task2 = Cms::Task.create!(
          :assigned_by => @editor_a,
          :assigned_to => @editor_b,
          :due_date => 1.minutes.ago,
          :comment => "Howdy Again!",
          :page => @page2)
    end


    def assert_that_the_page_is_assigned_to_the_assigned_to_user
      assert @page.assigned_to?(@editor_b), "Expected the page to be assigned to editor b"
      assert !@page.assigned_to?(@editor_a), "Expected the page not to be assigned to editor a"
    end

    def assert_that_the_task_is_added_to_the_users_incomplete_tasks
      assert !@editor_a.tasks.incomplete.to_a.include?(@task),
             "Expected Editor A's incomplete tasks not to include the task"
      assert !@editor_a.tasks.incomplete.to_a.include?(@task2),
             "Expected Editor A's incomplete tasks not to include the second task"
      assert @editor_b.tasks.incomplete.to_a.include?(@task),
             "Expected Editor B's incomplete tasks to include the task"
      assert @editor_b.tasks.incomplete.to_a.include?(@task2),
             "Expected Editor B's incomplete tasks to include the second task"
    end

  end

  class ExistingIncompleteTaskTest < TaskTest
    def setup
      super
      @existing_task = create(:task, :assigned_by => @editor_a, :assigned_to => @editor_b, :page => @page)
    end


    test "Existing task is incomplete, and assigned to Editor B's task list" do
      assert !@existing_task.completed?
      assert_equal @editor_b, @page.assigned_to
      assert @editor_b.tasks.incomplete.to_a.include?(@existing_task)
    end

    def test_create_task_for_a_page_with_existing_incomplete_tasks
      @new_task = create(:task, :assigned_by => @editor_b, :assigned_to => @editor_a, :page => @page)
      @existing_task = Cms::Task.find(@existing_task.id)

      assert @existing_task.completed?
      assert !@new_task.completed?
      assert @page.assigned_to?(@editor_a)
      assert !@page.assigned_to?(@editor_b)
      assert @editor_a.tasks.incomplete.to_a.include?(@new_task)
      assert !@editor_b.tasks.incomplete.to_a.include?(@existing_task)
    end

    test "Marking a task complete should mark it as unassigned" do
      @existing_task.mark_as_complete!

      assert @existing_task.completed?
      assert @page.assigned_to.nil?
      assert !@editor_b.tasks.incomplete.to_a.include?(@existing_task)
    end
  end
end
