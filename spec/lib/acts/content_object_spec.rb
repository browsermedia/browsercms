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

  it "should not dirty initial STATUSES" do
    Page.new
    HtmlBlock.statuses.keys.should_not include("HIDDEN")
  end

  it "should respond to status_name" do
    @b.status_name.should == "In Progress"
  end

  describe "dealing with DELETE operations" do
    it "should respond to delete" do
      @b.should respond_to(:delete)
    end

    it "should respond to deleted?" do
      @b.should respond_to(:deleted?)

    end
    it "should mark itself as deleted using the delete method, but not save the row." do
      @b.delete
      @b.status.should == "DELETED"
      @b.should be_deleted
      @b.version.should == 1
    end

    it "should create a new version when marking as deleted" do
      @b.save
      @b.reload.versions.size.should == 1
      @b.mark_as_deleted
      @b.reload.versions.size.should == 2
      @b.version.should == 2
      @b.versions.first.version.should == 1
    end

    it "should override destroy to prevent real destruction" do
      pending "Not sure if we should allow block.destroy method calls to really remove the row from the db (probably not)"
    end
  end
end