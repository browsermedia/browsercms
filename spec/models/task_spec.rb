require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "when a task is created" do
  before do
    @editor_a = create_admin_user(:login => "editor_a")
    @editor_b = create_admin_user(:login => "editor_b")
    @non_editor = create_user(:login => "non_editor")
    task = Task.new(:assigned_by => @assigner, :assigned_to => @assignee, :page => @page)
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
  end
  it "should not by completed" do
  end
  it "should allow a due date" do
  end
  it "should allow a comment" do
  end
  it "should send an email to the user the task was assigned to" do
  end
  it "should make the page be assigned to the assigned to user" do
  end
  it "should add the task to the user's incomplete tasks" do
  end
end

describe "when a task is assigned to someone else" do
  it "should create a new task" do
  end
  it "should complete the task" do
  end
  it "should not complete the new task" do
  end
  it "should make the page be assigned to the new user" do
  end
  it "should add the task to the new user's incomplete tasks" do
  end
  it "should remove the task to the previous user's incomplete tasks" do
  end
end

describe "when a task is completed" do
  it "should complete the task" do
  end
  it "should make the page be assigned to no one" do
  end
  it "should remove the task from the user's incomplete tasks" do
  end
end
