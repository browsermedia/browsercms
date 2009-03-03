require File.join(File.dirname(__FILE__), '/../../test_helper')

class TaskTest < ActiveSupport::TestCase
  def setup
    super
    @editor_a = create_admin_user(:login => "editor_a", :email => "editor_a@example.com")    
    @editor_b = create_admin_user(:login => "editor_b", :email => "editor_b@example.com")
    @non_editor = Factory(:user, :login => "non_editor", :email => "non_editor@example.com")
    @page = Factory(:page, :name => "Task Test", :path => "/task_test")          
  end
end
  
class CreateTaskTest < TaskTest

  def test_create_task
    assert_that_you_can_assign_a_task_to_yourself
    assert_that_an_assigned_by_user_that_is_an_editor_is_required
    assert_that_an_assigned_to_user_that_is_an_editor_is_required
    assert_that_a_page_is_required
  
    create_the_task!
  
    assert !@task.completed?
    assert(@task.due_date < Time.now)
    assert_equal "Howdy!", @task.comment
  
    assert_that_an_email_is_sent_to_the_user_the_task_was_assigned_to
    assert_that_the_page_is_assigned_to_the_assigned_to_user
    assert_that_the_task_is_added_to_the_users_incomplete_tasks
  end

  protected

    def assert_that_you_can_assign_a_task_to_yourself
      assert_valid Factory.build(:task, :assigned_by => @editor_a, :assigned_to => @editor_a)
    end

    def assert_that_an_assigned_by_user_that_is_an_editor_is_required
      task = Factory.build(:task, :assigned_by => nil, :assigned_to => @editor_a)
      assert_not_valid task
      assert_has_error_on task, :assigned_by_id, "is required"

      task = Factory.build(:task, :assigned_by => @non_editor, :assigned_to => @editor_a)
      assert_not_valid task
      assert_has_error_on task, :assigned_by_id, "cannot assign tasks"
    end
  
    def assert_that_an_assigned_to_user_that_is_an_editor_is_required
      task = Factory.build(:task, :assigned_by => @editor_a, :assigned_to => nil)
      assert_not_valid task
      assert_has_error_on task, :assigned_to_id, "is required"    

      task = Factory.build(:task, :assigned_by => @editor_a, :assigned_to => @non_editor)
      assert_not_valid task
      assert_has_error_on task, :assigned_to_id, "cannot be assigned tasks"      
    end
  
    def assert_that_a_page_is_required
      task = Factory.build(:task, :page => nil)
      assert_not_valid task
      assert_has_error_on task, :page_id, "is required"      
    end

    def create_the_task!
      @task = Task.create!(
        :assigned_by => @editor_a, 
        :assigned_to => @editor_b,
        :due_date => 5.minutes.ago,
        :comment => "Howdy!",
        :page => @page)      
    end

    def assert_that_an_email_is_sent_to_the_user_the_task_was_assigned_to
      email = EmailMessage.first(:order => "created_at desc")
      assert_equal @editor_a.email, email.sender
      assert_equal @editor_b.email, email.recipients
      assert_equal "Page '#{@page.name}' has been assigned to you", email.subject
      assert_equal "http://#{SITE_DOMAIN}#{@page.path}\n\n#{@task.comment}", email.body      
    end

    def assert_that_the_page_is_assigned_to_the_assigned_to_user
      assert @page.assigned_to?(@editor_b), "Expected the page to be assigned to editor b"
      assert !@page.assigned_to?(@editor_a), "Expected the page not to be assigned to editor a"
    end

    def assert_that_the_task_is_added_to_the_users_incomplete_tasks
      assert !@editor_a.tasks.incomplete.all.include?(@task), 
        "Expected Editor A's incomplete tasks not to include the task"
      assert @editor_b.tasks.incomplete.all.include?(@task),
        "Expected Editor B's incomplete tasks to include the task"      
    end
  
end

class ExistingIncompleteTaskTest < TaskTest
  def setup
    super
    @existing_task = Factory(:task, :assigned_by => @editor_a, :assigned_to => @editor_b, :page => @page)
  end

  def test_create_task_for_a_page_with_existing_incomplete_tasks
    assert !@existing_task.completed?
    
    @new_task = Factory(:task, :assigned_by => @editor_b, :assigned_to => @editor_a, :page => @page)
    @existing_task = Task.find(@existing_task.id)

    assert @existing_task.completed?
    assert !@new_task.completed?
    assert @page.assigned_to?(@editor_a)
    assert !@page.assigned_to?(@editor_b)
    assert @editor_a.tasks.incomplete.all.include?(@new_task)
    assert !@editor_b.tasks.incomplete.all.include?(@existing_task)
  end

  def test_completing_a_task
    assert !@existing_task.completed?
    assert_equal @editor_b, @page.assigned_to
    assert @editor_b.tasks.incomplete.all.include?(@existing_task)    

    @existing_task.mark_as_complete!
    
    assert @existing_task.completed?
    assert @page.assigned_to.nil?
    assert !@editor_b.tasks.incomplete.all.include?(@existing_task)    
  end
end
