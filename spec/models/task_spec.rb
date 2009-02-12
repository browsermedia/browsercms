require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "when a task is created it" do
  before do
    @editor_a = create_admin_user(:login => "editor_a", :email => "editor_a@example.com")
    @editor_b = create_admin_user(:login => "editor_b", :email => "editor_b@example.com")
    @non_editor = create_user(:login => "non_editor", :email => "non_editor@example.com")
    @page = create_page(:name => "Task Test", :path => "/task_test")
  end
  it "should allow you to assign the task to yourself" do
    new_task(:assigned_by => @editor_a, :assigned_to => @editor_a).should be_valid
  end
  
  it "should require an assigned_by user that has edit_content or publish_content permission" do
    new_task(:assigned_by => @editor_a, :assigned_to => @editor_b).should be_valid

    task = new_task(:assigned_by => nil, :assigned_to => @editor_a)
    task.should_not be_valid
    task.errors.on(:assigned_by_id).should == "is required" 
    
    task = new_task(:assigned_by => @non_editor, :assigned_to => @editor_a)
    task.should_not be_valid
    task.errors.on(:assigned_by_id).should == "cannot assign tasks"     
  end
  
  it "should require an assigned_to user that has edit_content or publish_content permission" do
    new_task(:assigned_by => @editor_a, :assigned_to => @editor_b).should be_valid

    task = new_task(:assigned_by => @editor_a, :assigned_to => nil)
    task.should_not be_valid
    task.errors.on(:assigned_to_id).should == "is required" 
    
    task = new_task(:assigned_by => @editor_a, :assigned_to => @non_editor)
    task.should_not be_valid
    task.errors.on(:assigned_to_id).should == "cannot be assigned tasks"     
  end
  
  it "should require a page" do
    task = new_task(:page => nil)
    task.should_not be_valid
    task.errors.on(:page_id).should == "is required"
  end
  it "should not be completed" do
    task = create_task(:assigned_by => @editor_a, :assigned_to => @editor_b)
    task.should_not be_completed
  end
  it "should allow a due date" do
    task = create_task(:assigned_by => @editor_a, :assigned_to => @editor_b, :due_date => 5.minutes.ago)
    task.due_date.should < Time.now
  end
  it "should allow a comment" do
    task = create_task(:assigned_by => @editor_a, :assigned_to => @editor_b, :comment => "Howdy!")
    task.comment.should == "Howdy!"
  end
  it "should send an email to the user the task was assigned to" do
    task = create_task(:assigned_by => @editor_a, :assigned_to => @editor_b, :page => @page, :comment => "Howdy!")
    email = EmailMessage.first(:order => "created_at desc")
    email.sender.should == @editor_a.email
    email.recipients.should == @editor_b.email
    email.subject.should == "Page '#{@page.name}' has been assigned to you"
    email.body.should == "http://#{SITE_DOMAIN}#{@page.path}\n\n#{task.comment}"
  end
  it "should make the page be assigned to the assigned to user" do
    create_task(:assigned_by => @editor_a, :assigned_to => @editor_b, :page => @page)
    @page.should be_assigned_to(@editor_b)
    @page.should_not be_assigned_to(@editor_a)
  end
  it "should add the task to the user's incomplete tasks" do
    task = create_task(:assigned_by => @editor_a, :assigned_to => @editor_b, :page => @page)
    @editor_a.tasks.incomplete.should_not include(task)
    @editor_b.tasks.incomplete.should include(task)
  end
end

describe "when a task is created for a page with an existing incomplete task" do
  before do
    @editor_a = create_admin_user(:login => "editor_a", :email => "editor_a@example.com")
    @editor_b = create_admin_user(:login => "editor_b", :email => "editor_b@example.com")
    @non_editor = create_user(:login => "non_editor", :email => "non_editor@example.com")
    @page = create_page(:name => "Task Test", :path => "/task_test")
    @task = create_task(:assigned_by => @editor_a, :assigned_to => @editor_b, :page => @page)
  end  
  it "should complete the existing tasks for that page" do
    @task.should_not be_completed
    create_task(:assigned_by => @editor_b, :assigned_to => @editor_a, :page => @page)
    reset(:task)
    @task.should be_completed
  end
  it "should not complete the new task" do
    task = create_task(:assigned_by => @editor_b, :assigned_to => @editor_a, :page => @page)
    task.should_not be_completed
  end
  it "should make the page be assigned to the new user" do
    create_task(:assigned_by => @editor_b, :assigned_to => @editor_a, :page => @page)
    @page.should be_assigned_to(@editor_a)  
    @page.should_not be_assigned_to(@editor_b)  
  end
  it "should add the task to the new user's incomplete tasks" do
    task = create_task(:assigned_by => @editor_b, :assigned_to => @editor_a, :page => @page)
    @editor_a.tasks.incomplete.should include(task)
  end
  it "should remove the task to the previous user's incomplete tasks" do
    task = create_task(:assigned_by => @editor_b, :assigned_to => @editor_a, :page => @page)
    @editor_b.tasks.incomplete.should_not include(task)    
  end
end

describe "when a task is completed it" do
  before do
    @editor_a = create_admin_user(:login => "editor_a", :email => "editor_a@example.com")
    @editor_b = create_admin_user(:login => "editor_b", :email => "editor_b@example.com")
    @non_editor = create_user(:login => "non_editor", :email => "non_editor@example.com")
    @page = create_page(:name => "Task Test", :path => "/task_test")
    @task = create_task(:assigned_by => @editor_a, :assigned_to => @editor_b, :page => @page)
  end  
  it "should complete the task" do
    @task.should_not be_completed
    @task.mark_as_complete!
    @task.should be_completed
  end
  it "should make the page be assigned to no one" do
    @page.assigned_to.should == @editor_b
    @task.mark_as_complete! 
    @page.assigned_to.should be_nil
  end
  it "should remove the task from the user's incomplete tasks" do
    @editor_b.tasks.incomplete.all.should include(@task)
    @task.mark_as_complete!
    @editor_b.tasks.incomplete.all.should_not include(@task)
  end
end
