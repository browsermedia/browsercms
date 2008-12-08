require File.dirname(__FILE__) + '/../../spec_helper'

describe "A Content Block", :type => :model do
  before(:each) do
    @block = create_html_block(:name => "Test")
  end

  it "should add a default status to a block" do
    @block.should_not be_published
  end

  it "should allow blocks to be published" do
    @block.publish
    @block = HtmlBlock.find(@block.id)
    @block.should be_published
  end

  it "should be published if it is published" do
    @block.publish
    @block.should be_published
  end

  it "should not be published if it is not published" do
    @block.should_not be_published
  end

  it "should allow blocks to be marked as draft" do
    @block.publish
    @block.publish_on_save = false
    @block.save!
    @block.reload.should_not be_published
  end

  it "should be versioned" do
    @block.class.should be_versioned
  end

  it "should respond to publish?" do
    @block.publish
    @block.should be_published
  end

  it "should respond to in_progress?" do
    @block.publish_on_save = false
    @block.should_not be_published
  end

  it "should respond to status_name" do
    @block.status_name.should == "Draft"
  end

  describe "when destroying a content object" do
    describe "that is not versionable" do
      before(:each) do
        @p = create_dynamic_portlet
      end
      it "should be deleted" do
        @p.destroy.should be_true
      end
    end
  end
  
  describe "revision comment" do
    it "should be set to 'Created' if it is a new instance" do
      @block.current_version.version_comment.should == 'Created'
      @block.as_of_version(@block.version).current_version.version_comment.should == 'Created'
    end
    it "should be set to 'Name, Content edited' if name and content were changed" do
      @block.name = "Something Else"
      @block.content = "Whatever"
      @block.save
      @block.current_version.version_comment.should == 'Changed content, name'
      @block.as_of_version(@block.version).current_version.version_comment.should == 'Changed content, name'
    end
    it "should not be changed if the object is not changed" do
      @block.reload.save
      @block.current_version.version_comment.should == 'Created'
      @block.as_of_version(@block.version).current_version.version_comment.should == 'Created'
    end
    it "should be set to the value of version_comment if one is set" do
      @block.update_attributes(:name => "Something Else", :version_comment => "Something Changed")
      @block.save
      @block.current_version.version_comment.should == "Something Changed"
      @block.as_of_version(@block.version).current_version.version_comment.should == "Something Changed"
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
        @block.publish!
        @block.name = "Whatever"
        @block.save!
        @block.should_not be_published
      end
    end
  end
  describe "a non-versioned block that is connected to a page" do
    describe "when it is edited" do
      before do
        @page = create_page(:section => root_section)
        @block = create_dynamic_portlet(:name => "Test Portlet")
        @page.create_connector(@block, "main")
        reset(:page, :block)
        @editing_the_block = lambda {@block.update_attributes(:name => "something different")}
      end
      it "should not change the page version" do
        @editing_the_block.call
        @page.reload.version.should == 2
      end
      it "should not create a new page version" do
        @editing_the_block.should_not change(Page::Version, :count)
      end
      it "should set the revision comment on the page" do
        @editing_the_block.call
        @page.reload.current_version.version_comment.should == "Dynamic Portlet 'Test Portlet' was added to the 'main' container"
      end
      it "should create the right connectors" do
        @editing_the_block.call
        conns = Connector.for_connectable(@block).all(:order => 'id')
        conns.size.should == 1
        conns[0].should_meet_expectations(:page => @page, :page_version => 2, :connectable => @block, :connectable_version => nil, :container => "main")        
      end
      describe "and saved" do
        it "the page should not be published" do
          @editing_the_block.call
          @page.should_not be_published
        end
      end
      describe "and save and published" do
        describe "and the page is draft then," do
          before do
            @editing_the_block = lambda {@block.update_attributes(:name => "something different", :publish_on_save => true)}
          end
          it "the page should be published" do
            @editing_the_block.call
            @page.reload.should_not be_published
          end
        end
        describe "and the page is published then," do
          before do
            @page.publish!
            reset(:page)
            @editing_the_block = lambda {@block.update_attributes(:name => "something different", :publish_on_save => true)}
          end
          it "the page should be published" do
            @editing_the_block.call
            reset(:page)
            @page.should be_published
          end
        end
      end
    end    
  end
  describe "a block that is connected to a page" do
    describe "when it is edited" do
      before do
        @page = create_page(:section => root_section)
        @page.create_connector(@block, "main")
        reset(:page, :block)
        @editing_the_block = lambda {@block.update_attribute(:name, "something different")}
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
        @page.reload.current_version.version_comment.should =~ /^Edited HtmlBlock#\d+/
      end
      it "should create the right connectors" do
        @editing_the_block.call
        conns = @block.connectors.all(:order => 'id')
        conns.size.should == 2
        conns[0].should_meet_expectations(:page => @page, :page_version => 2, :connectable => @block, :connectable_version => 1, :container => "main")        
        conns[1].should_meet_expectations(:page => @page, :page_version => 3, :connectable => @block, :connectable_version => 2, :container => "main")        
      end
      describe "and saved" do
        it "the page should not be published" do
          @editing_the_block.call
          @page.should_not be_published
        end
      end
      describe "and save and published" do
        describe "and the page is draft then," do
          before do
            @editing_the_block = lambda {@block.reload.update_attributes(:name => "something different", :publish_on_save => true)}
          end
          it "the page should be published" do
            @editing_the_block.call
            @page.reload.should_not be_published
          end
        end
        describe "and the page is published then," do
          before do
            @page.publish!
            reset(:page)
            @editing_the_block = lambda {@block.reload.update_attributes(:name => "something different", :publish_on_save => true)}
          end
          it "the page should be published" do
            @editing_the_block.call
            reset(:page)
            @page.should be_published
          end
        end
      end
    end
  end 
end

describe "Destroying a block", :type => :model do
  before do
    @block = create_html_block
    @destroying_the_block = lambda { @block.destroy }
  end

  it "should make the block be deleted" do
    @destroying_the_block.call 
    @block.should be_deleted
  end
  it "should make the block not exist?" do
    @destroying_the_block.call
    HtmlBlock.exists?(@block.id).should be_false
  end
  it "should make the block not exist? if called with conditions" do
    @destroying_the_block.call
    HtmlBlock.exists?(["name = ?", @block.name]).should be_false
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
    HtmlBlock.delete_all(["name = ?", @block.name])
    lambda { HtmlBlock.find(@block.id)}.should raise_error
    d = HtmlBlock.find_with_deleted(@block.id)
    d.should be_deleted  
  end

  it "should mark the latest row as deleted" do
    @destroying_the_block.call
    d = HtmlBlock.find_with_deleted(@block.id)
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

end