require File.dirname(__FILE__) + '/../../spec_helper'

describe "A Content Object" do
  before(:each) do
    @b = create_html_block(:name => "Test")
  end

  it "should add a default status to a block" do
    @b.status.should == "IN_PROGRESS"
  end

  it "should allow blocks to be published" do
    @b.publish(create_user)
    @b = HtmlBlock.find(@b.id)
    @b.status.should == "PUBLISHED"
  end

  it "should be live if the status is PUBLISHED" do
    @b.publish(create_user)
    @b.should be_live
  end

  it "should not be live if the status is not PUBLISHED" do
    @b.should_not be_live
  end

  it "should allow blocks to be archived" do
    @b.archive(create_user)
    @b.reload.status.should == 'ARCHIVED'
  end

  it "should allow blocks to be marked 'in progress'" do
    @b.publish(create_user)
    @b.in_progress(create_user)
    @b.reload.status.should == 'IN_PROGRESS'
  end

  it "should not add 'hide' to blocks, since they can't be hidden" do
    lambda { @b.hide(create_user) }.should raise_error(NoMethodError)
  end

  it "should respond to ! versions of same status methods" do
    @b.should respond_to(:in_progress!)
    @b.should respond_to(:archive!)
    @b.should respond_to(:publish!)
    @b.should_not respond_to(:hide!)
  end

  it "should not allow invalid statuses" do
    @b = HtmlBlock.new(:new_status => "FAIL")
    @b.should_not be_valid
    @b.errors.on(:status).should_not be_empty
    #@b.should have(1).error_on(:status)
  end

  it "should respond to publish?" do
    @b.publish(create_user)
    @b.should be_published
  end

  it "should respond to archive?" do
    @b.archive(create_user)
    @b.should be_archived
  end

  it "should respond to in_progress?" do
    @b.in_progress(create_user)
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
    describe "which is versioned" do
      before(:each) do
        @b = HtmlBlock.find(@b.id)
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

      it "should support versioning" do
        @b.supports_versioning?.should be_true
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

    describe "that is not versionable" do
      before(:each) do
        @p = create_portlet
      end
      it "should be deleted" do
        @p.destroy.should be_true
      end
    end
  end
  
  describe "revision comment" do
    it "should be set to 'Created' if it is a new instance" do
      @b.revision_comment.should == 'Created'
      @b.as_of_version(@b.version).revision_comment.should == 'Created'
    end
    it "should be set to 'Name, Content edited' if name and content were changed" do
      @b.name = "Something Else"
      @b.content = "Whatever"
      @b.save
      @b.revision_comment.should == 'Name, Content edited'
      @b.as_of_version(@b.version).revision_comment.should == 'Name, Content edited'
    end
    it "should not be changed if the object is not changed" do
      @b.reload.save
      @b.revision_comment.should == 'Created'
      @b.as_of_version(@b.version).revision_comment.should == 'Created'
    end
    it "should be set to the value of new_revision_comment if one is set" do
      @b.update_attributes(:name => "Something Else", :new_revision_comment => "Something Changed")
      @b.save
      @b.revision_comment.should == "Something Changed"
      @b.as_of_version(@b.version).revision_comment.should == "Something Changed"
    end
  end
  
  describe "saving" do
    describe "with a new status" do
      it "should should be published" do
        @b.update_attribute(:new_status, "PUBLISHED")
        @b.save
        @b.should be_published
      end
    end
    describe "without a new status" do
      it "should be in progress" do
        @b.publish!(create_user)
        @b.update_attribute(:name, "Whatever")
        @b.save
        @b.should be_in_progress
      end
    end
  end
  describe "a block that is connected to a page" do
    describe "when it is edited" do
      before do
        @page = create_page(:section => root_section)
        @page.add_content_block!(@b, "main")
        @editing_the_block = lambda {@b.update_attribute(:name, "something different")}
      end
      it "should work" do
        pending "Need to test for blocks that don't have versioning"
      end
      it "should change page version by 1" do
        @editing_the_block.call
        @page.reload.version.should == 3
      end
      it "should create a new page version" do
        @editing_the_block.should change(Page::Version, :count).by(1)
      end
      it "should set the revision comment on the page" do
        @editing_the_block.call
        @page.reload.revision_comment.should =~ /^Edited block.*/
      end
      it "should create the right connectors" do
        @editing_the_block.call
        conns = Connector.all(:conditions => ["content_block_id = ? and content_block_type = ?", @b.id, @b.class.name], :order => 'id')
        conns.size.should == 2
        conns[0].should_meet_expectations(:page => @page, :page_version => 2, :content_block => @b, :content_block_version => 1, :container => "main")        
        conns[1].should_meet_expectations(:page => @page, :page_version => 3, :content_block => @b, :content_block_version => 2, :container => "main")        
      end
      describe "and saved" do
        it "the page should not be live" do
          @editing_the_block.call
          @page.should_not be_live
        end
      end
      describe "and save and published" do
        before do
          @editing_the_block = lambda {@b.update_attributes(:name => "something different", :new_status => "PUBLISHED")}
        end
        it "the page should be live" do
          @editing_the_block.call
          @page.reload.should be_live
        end
      end
    end
  end
  
  
  
end