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

  describe "when destroying a content object" do
    before(:each) do
      @b.save
      @b.reload
    end

    it "should implement deleted? so that it uses status" do
      @b.status = "DELETED"
      @b.deleted?.should == true
    end

    it "should not exist?" do
      pending "Make exist? not find deleted objects"
      @b.destroy
      HtmlBlock.exists?(@b.id).should == false
    end

    it "should not be counted" do
      pending "Make count work"
    end

    it "should make delete_all mark as deleted" do
      pending "Make delete_all work"
    end

    it "should not be findable" do
      @b.destroy
      lambda { HtmlBlock.find(@b) }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should mark the latest row as deleted" do
      @b.destroy
      d = HtmlBlock.find_with_deleted(@b)
      d.status.should == "DELETED"
      d.should be_deleted
    end

    it "should create a new version when destroying" do
      @b.versions.size.should == 1
      @b.destroy
      d = HtmlBlock.find_with_deleted(@b)
      d.versions.size.should == 2
      d.version.should == 2
      d.versions.first.version.should == 1
    end

    it "should not remove all versions as well when doing a destroy" do
      @b.destroy
      HtmlBlock::Version.find(:all, "html_block_id =>#{@b.id}").size.should == 2
    end

    it "should remove all versions when doing destroy!" do
      @b.destroy!
      lambda { HtmlBlock.find_with_deleted(@b) }.should raise_error(ActiveRecord::RecordNotFound)
      HtmlBlock::Version.find(:all, "html_block_id =>#{@b.id}").size.should == 0
    end
  end
end