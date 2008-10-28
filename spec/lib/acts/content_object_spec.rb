require File.dirname(__FILE__) + '/../../spec_helper'

describe "A Content Object" do
  before(:each) do
    @block = create_html_block(:name => "Test")
  end

  it "should add a default status to a block" do
    @block.should be_draft
  end

  it "should allow blocks to be published" do
    @block.publish(create_user)
    @block = HtmlBlock.find(@block.id)
    @block.should be_published
  end

  it "should be live if it is published" do
    @block.publish(create_user)
    @block.should be_live
  end

  it "should not be live if it is not published" do
    @block.should_not be_live
  end

  it "should allow blocks to be marked as draft" do
    @block.publish(create_user)
    @block.publish_on_save = false
    @block.save!
    @block.reload.should be_draft
  end

  it "should support versioning" do
    @block.should be_versionable
  end

  it "should respond to publish?" do
    @block.publish(create_user)
    @block.should be_published
  end

  it "should respond to in_progress?" do
    @block.publish_on_save = false
    @block.should be_draft
  end

  it "should respond to status_name" do
    @block.status_name.should == "Draft"
  end

  describe "when destroying a content object" do
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
      @block.revision_comment.should == 'Created'
      @block.as_of_version(@block.version).revision_comment.should == 'Created'
    end
    it "should be set to 'Name, Content edited' if name and content were changed" do
      @block.name = "Something Else"
      @block.content = "Whatever"
      @block.save
      @block.revision_comment.should == 'Name, Content edited'
      @block.as_of_version(@block.version).revision_comment.should == 'Name, Content edited'
    end
    it "should not be changed if the object is not changed" do
      @block.reload.save
      @block.revision_comment.should == 'Created'
      @block.as_of_version(@block.version).revision_comment.should == 'Created'
    end
    it "should be set to the value of new_revision_comment if one is set" do
      @block.update_attributes(:name => "Something Else", :new_revision_comment => "Something Changed")
      @block.save
      @block.revision_comment.should == "Something Changed"
      @block.as_of_version(@block.version).revision_comment.should == "Something Changed"
    end
  end
  
  describe "saving" do
    describe "with a new status" do
      it "should should be published" do
        @block.publish_on_save = true
        @block.save
        @block.should be_published
      end
    end
    describe "without a new status" do
      it "should be draft" do
        @block.publish!(create_user)
        @block.name = "Whatever"
        @block.save!
        @block.should be_draft
      end
    end
  end
  describe "updating revision" do
    it "should mark a content object as dirty anytime a comment is updated" do
      @block.new_revision_comment = @block.revision_comment
      @block.should be_changed
    end
  end
  describe "a block that is connected to a page" do
    describe "when it is edited" do
      before do
        @page = create_page(:section => root_section)
        @page.add_content_block!(@block, "main")
        @editing_the_block = lambda {@block.update_attribute(:name, "something different")}
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
        conns = Connector.all(:conditions => ["content_block_id = ? and content_block_type = ?", @block.id, @block.class.name], :order => 'id')
        conns.size.should == 2
        conns[0].should_meet_expectations(:page => @page, :page_version => 2, :content_block => @block, :content_block_version => 1, :container => "main")        
        conns[1].should_meet_expectations(:page => @page, :page_version => 3, :content_block => @block, :content_block_version => 2, :container => "main")        
      end
      describe "and saved" do
        it "the page should not be live" do
          @editing_the_block.call
          @page.should_not be_live
        end
      end
      describe "and save and published" do
        describe "and the page is draft then," do
          before do
            @editing_the_block = lambda {@block.update_attributes(:name => "something different", :publish_on_save => true)}
          end
          it "the page should be live" do
            @editing_the_block.call
            @page.reload.should_not be_live
          end
        end
        describe "and the page is live then," do
          before do
            @page.publish!(create_user)
            @page.reload
            @editing_the_block = lambda {@block.update_attributes(:name => "something different", :publish_on_save => true)}
          end
          it "the page should be live" do
            @editing_the_block.call
            @page.reload.should be_live
          end
        end
      end
    end
  end 
end

describe "Destroying a block" do
  before do
    @block = create_html_block
    @destroying_the_block = lambda { @block.destroy }
  end

  it "should make the block be deleted" do
    @destroying_the_block.call 
    @block.should be_deleted
  end
  it "should make the block not exist?" do
    pending "Make exist? not find deleted objects"
    @destroying_the_block.call
    HtmlBlock.exists?(@block.id).should == false
  end
  it "should make the block be not findable" do
    @destroying_the_block.call
    lambda { HtmlBlock.find(@b) }.should raise_error(ActiveRecord::RecordNotFound)
  end
  it "should make the block be not be counted" do
    @destroying_the_block.should change(HtmlBlock, :count).by(-1)
  end

  it "should raise an error when a dynamic finder is called" do
    @destroying_the_block.call    
    lambda { HtmlBlock.find_by_name("foo") }.should raise_error
  end

  it "should make delete_all mark as deleted" do
    pending "Make delete_all work"
  end

  it "should mark the latest row as deleted" do
    @destroying_the_block.call
    d = HtmlBlock.find_with_deleted(@block)
    d.should be_deleted
  end

  it "should create a new version when destroying" do
    @block.versions.size.should == 1
    @destroying_the_block.call
    d = HtmlBlock.find_with_deleted(@block)
    d.versions.size.should == 2
    d.version.should == 2
    d.versions.first.version.should == 1
  end

  it "should not remove all versions as well when doing a destroy" do
    @destroying_the_block.call
    HtmlBlock::Version.find(:all, "html_block_id =>#{@block.id}").size.should == 2
  end

  it "should remove all versions when doing destroy!" do
    @block.destroy!
    lambda { HtmlBlock.find_with_deleted(@b) }.should raise_error(ActiveRecord::RecordNotFound)
    HtmlBlock::Version.find(:all, "html_block_id =>#{@block.id}").size.should == 0
  end    
end