require File.dirname(__FILE__) + '/../../spec_helper'

describe "A Content Object" do
  before(:each) do
    @b = HtmlBlock.new
    @b.valid?
  end

  it "should add a default status to a block" do
    @b.status.should == "IN_PROGRESS"
  end

  it "should allow blocks to be published" do
    @b.publish
    @b.reload.status.should == "PUBLISHED"
  end

  it "should allow blocks to be archived" do
    @b.archive
    @b.reload.status.should == 'ARCHIVED'
  end

  it "should allow blocks to be marked 'in progress'" do
    @b.publish
    @b.in_progress
    @b.reload.status.should == 'IN_PROGRESS'
  end

  it "should not add 'hide' to blocks, since they can't be hidden" do
    lambda { @b.hide }.should raise_error(NoMethodError)
  end

  it "should respond to ! versions of same status methods" do
    @b.should respond_to(:in_progress!)
    @b.should respond_to(:archive!)
    @b.should respond_to(:publish!)
    @b.should_not respond_to(:hide!)
  end

  it "should not allow invalid statuses" do
    @b = HtmlBlock.new(:status => "FAIL")
    @b.should_not be_valid
    @b.should have(1).error_on(:status)
  end

  it "should respond to publish?" do
    @b.publish
    @b.should be_published
  end

  it "should respond to archive?" do
    @b.archive
    @b.should be_archived
  end

  it "should respond to in_progress?" do
    @b.in_progress
    @b.should be_in_progress
  end

  it "should respond to deleted?" do
    @b.delete
    @b.should be_deleted
  end

  it "should not dirty initial STATUSES" do
    Page.new
    HtmlBlock.statuses.keys.should_not include("HIDDEN")
  end
  
  it "should respond to status_name" do
    @b.status_name.should == "In Progress"
  end
  
end