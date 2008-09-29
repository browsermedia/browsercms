require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Page do
  it "should validate uniqueness of path" do
    create_page(:path => "test", :section => root_section)
    page = new_page(:path => "test", :section => root_section)
    page.should_not be_valid
    page.should have(1).error_on(:path)
  end
  
  it "should require an updated_by_user on create" do
    page = new_page(:path => "test", :section => root_section, :updated_by_user => nil)    
    page.should_not be_valid
    page.should have(1).error_on(:updated_by_id)
  end
  
  it "should require an updated_by_user on update" do
    page = create_page(:path => "test", :section => root_section)
    page = Page.find(page.id)
    page.should_not be_valid
    page.should have(1).error_on(:updated_by_id)
  end

  it "should be valid if an updated_by_user is specified" do
    page = create_page(:path => "test", :section => root_section)
    page = Page.find(page.id)
    page.updated_by_user = User.first
    page.should be_valid
  end

  describe ".find_by_path" do
    it "should be able to find the home page" do
      @page = create_page(:path => nil)
      Page.find_by_path("/").should == @page
    end
    it "should be able to find another page" do
      @page = create_page(:path => "about")
      Page.find_by_path("/about").should == @page
    end
  end

  it "should prepend a '/' to the path" do
    page = new_page(:path => 'foo/bar')
    page.should be_valid
    page.path.should == "/foo/bar"
  end

  it "should not prepened a '/' to the path if there already is one" do
    page = new_page(:path => '/foo/bar')
    page.should be_valid
    page.path.should == "/foo/bar"
  end

  it "should set path to '/' if it is nil" do
    page = new_page(:path => nil)
    page.should be_valid
    page.path.should == "/"
  end

  describe "status" do
    it "should be in progress when it is created" do
      page = create_page
      page.should be_in_progress
      page.should_not be_published
    end

    it "should be able to be published when creating" do
      page = new_page
      page.publish.should be_true
      page.should be_published
    end

    it "should be able to be hidden" do
      page = create_page
      page.hide!
      page.should be_hidden
    end

    it "should not allow invalid statuses" do
      page = new_page(:status => "FAIL")
      page.should have(1).error_on(:status)
    end

  end

  it "should be able to be moved to another section" do
    root = create_section
    section = create_section(:name => "Another", :parent => root)
    page = create_page(:section => root)
    page.section.should_not == section
    page.move_to(section, User.first)
    page.section.should == section
  end

  describe "move_to" do
    before do
      @from_section = create_section(:name => "From", :parent => root_section)
      @to_section = create_section(:name => "To", :parent => root_section)
      @page = create_page(:section => @from_section, :name => "Mover")
      @action = lambda { @page.move_to(@to_section, User.first) }
    end
    it "should create a new version of the page" do
      @action.should change(Page::Version, :count).by(1)
    end
    it "should not create a new page" do
      @action.should_not change(Page, :count)
    end
    it "should update the page's section_id" do
      @action.call
      @page.reload.section_id.should == @to_section.id
    end
  end

  describe "Versioning" do

    describe "when creating a record" do
      before do
        @page = create_page
      end
      it "should create a version when creating a page" do
        @page.versions.latest.page.should == @page
      end
    end

    describe "when updating attributes" do
      describe "with different values" do
        before do
          @first_guy = create_user(:login => "first_guy")
          @page = create_page(:name => "Original Value", :updated_by_user => @first_guy)
          @page = Page.find(@page.id)
          @new_guy = create_user(:login => "new_guy")
          @page.update_attributes(:name => "Something Different", :updated_by_user => @new_guy)
        end
        it "should create a version with the changed values" do
          @page.versions.latest.page.should == @page
          @page.versions.latest.name.should == "Something Different"
          @page.name.should == "Something Different"
        end
        it "should not affect the values in previous versions" do
          @page.versions.first.name.should == "Original Value"
        end
        it "should be able to tell who created each revision" do
          @page.versions.first.updated_by.should == @first_guy
          @page.versions.last.updated_by.should == @new_guy          
        end
      end
      describe "with the unchanged values" do
        before do
          @page = create_page(:name => "Original Value")
          @update_attributes = lambda { @page.update_attributes(:name => "Original Value") }
        end
        it "should not create a new version" do
          @update_attributes.should_not change(@page.versions, :count)
        end
      end
    end

    describe "when deleting a record" do
      # This section duplicates a bit of content_object_spec for handling destroy
      before do
        @page = create_page
        @delete_page = lambda { @page.destroy }
      end

      it "should not actually delete the row" do
        @delete_page.should_not change(Page, :count)
      end
      it "should create a new version" do
        @delete_page.should change(@page.versions, :count).by(1)
      end

      it "should create a new version when destroying" do
        @page.versions.size.should == 1
        @page.destroy
        d = Page.find_with_deleted(@page)
        d.versions.size.should == 2
        d.version.should == 2
        d.versions.first.version.should == 1
      end

      it "should set the status to DELETED" do
        @delete_page.call
        @page.should be_deleted
      end

      it "should not be findable" do
        @page.destroy
        lambda { Page.find(@page) }.should raise_error(ActiveRecord::RecordNotFound)
      end

      it "should not remove all versions as well when doing a destroy" do
        @page.destroy
        Page::Version.find(:all, "page_id =>#{@page.id}").size.should == 2
      end

      it "should remove all versions when doing destroy!" do
        @page.destroy!
        lambda { Page.find_with_deleted(@page) }.should raise_error(ActiveRecord::RecordNotFound)
        Page::Version.find(:all, "page_id =>#{@page.id}").size.should == 0
      end
    end
    
    describe "#increment_version!" do
      before do
        @page = create_page(:section => root_section)
        @increment_version = lambda { @page.increment_version! }
      end
      it "should increase the version number" do
        @increment_version.call
        @page.reload.version.should == 2
      end
      it "should create a new version" do
        @increment_version.should change(Page::Version, :count).by(1)
      end
      it "should recieve normal update callbacks" do
        @page.should_receive(:before_update).and_return(true)
        @page.should_receive(:after_update).and_return(true)
        @increment_version.call
      end
      
    end 
  end
end

describe "A page with associated blocks" do
  before do
    @page = create_page(:section => root_section)
    @block = create_html_block
    @other_connector = create_connector(:page => create_page(:section => root_section), :content_block => @block)
    @page_connector = create_connector(:page => @page, :content_block => @block)          
    @destroying_the_page = lambda { @page.destroy }
  end
  describe "when deleted" do
    it "should remove one record from the connectors table" do
      @destroying_the_page.should change(Connector, :count).by(-1)
    end
    it "should deleted the page's connectors" do
      @destroying_the_page.call
      Connector.exists?(@page_connector.id).should be_false
    end
    it "should not deleted other connectors" do
      @destroying_the_page.call
      Connector.exists?(@other_connector.id).should be_true
    end
    it "should not delete the blocks" do
      @destroying_the_page.call
      HtmlBlock.exists?(@block.id).should be_true
      @block.should_not be_deleted
    end
  end
  describe "when destroyed!" do
    it "should do what it does (TBD)" do
      pending "Make work"
    end
  end
end

describe "When adding a block to a page" do
  before do
    @page = create_page(:section => root_section)
    @block = create_html_block()
    @adding_block = lambda { @conn = @page.add_content_block!(@block, "testing") }
  end
  it "should set the page version to new page version" do
    @adding_block.call
    @conn.page_version.should == 2
  end
  it "should set the content block version to existing block version" do
    @adding_block.call
    @conn.content_block_version.should == 1
  end
  it "should increment the page version by 1" do
    @adding_block.should change(@page, :version).by(1)
  end
  it "should create 1 new connector" do
    @adding_block.should change(Connector, :count).by(1)
  end
end

describe "When adding a second block to a page" do
  before do
    @page = create_page(:section => root_section)
    @block = create_html_block()
    @block2 = create_html_block()
    @first_conn = @page.add_content_block!(@block, "testing")
    @adding_block = lambda do
      @conn = @page.add_content_block!(@block2, "testing")      
    end
  end
  it "should set the page version to new page version" do
    @adding_block.call
    @conn.page_version.should == 3
  end
  it "should set the content block version to existing block version" do
    @adding_block.call
    @conn.content_block_version.should == 1
  end
  it "should increment the page version by 1" do
    @adding_block.should change(@page, :version).by(1)
  end    
  it "should add 2 new connectors to the page" do
    @adding_block.call 
    @page.connectors.count.should == 2
  end
  it "should create 2 new connectors" do
    @adding_block.should change(Connector, :count).by(2)
  end
  it "should leave the connector for the first block untouched" do
    @adding_block.call
    @first_conn.reload
    @first_conn.content_block.should == @block
    @first_conn.page.should == @page
    @first_conn.page_version.should == 2
    @first_conn.content_block_version.should == 1
  end
  it "should correctly wire up the 2 new connectors" do
    @adding_block.call
    @conns = Connector.all(:conditions => {:page_version => 3}, :order => "id")
    @conns.size.should == 2
    @conns[0].content_block.should == @block
    @conns[0].page.should == @page
    @conns[0].page_version.should == 3
    @conns[0].content_block_version.should == 1
    
    @conns[1].content_block.should == @block2
    @conns[1].page.should == @page
    @conns[1].page_version.should == 3
    @conns[1].content_block_version.should == 1
  end
end

describe "When adding a third block to a page" do
  before do
    @page = create_page(:section => root_section)
    @block = create_html_block()
    @block2 = create_html_block()
    @first_conn = @page.add_content_block!(@block, "testing")
    @second_conn = @page.add_content_block!(@block2, "testing")
    @adding_block = lambda do
      @conn = @page.add_content_block!(@block2, "testing")
    end
  end
  it "should set the page version to 4" do
    @adding_block.call
    @page.reload.version.should == 4
  end
  it "should set the page version to new page version" do
    @adding_block.call
    @conn.page_version.should == 4
  end
  it "should set the content block version to existing block version" do
    @adding_block.call
    @conn.content_block_version.should == 1
  end
  it "should increment the page version by 1" do
    @adding_block.should change(@page, :version).by(1)
  end    
  it "should add 3 new connectors to the page" do
    @adding_block.call 
    @page.connectors.count.should == 3
  end
  it "should create 3 new connectors" do
    @adding_block.should change(Connector, :count).by(3)
  end
  it "should leave the previous connectors untouched" do
    @adding_block.call
    @conns = Connector.all(:conditions => ["page_version < 4"], :order => "id")
    @conns.size.should == 3

    @conns[0].content_block.should == @block
    @conns[0].page.should == @page
    @conns[0].page_version.should == 2
    @conns[0].content_block_version.should == 1
        
    @conns[1].content_block.should == @block
    @conns[1].page.should == @page
    @conns[1].page_version.should == 3
    @conns[1].content_block_version.should == 1
    
    @conns[2].content_block.should == @block2
    @conns[2].page.should == @page
    @conns[2].page_version.should == 3
    @conns[2].content_block_version.should == 1    
  end
  it "should correctly wire up the 3 new connectors" do
    @adding_block.call
    @conns = Connector.all(:conditions => {:page_version => 4}, :order => "id")
    @conns.size.should == 3
    @conns[0].content_block.should == @block
    @conns[0].page.should == @page
    @conns[0].page_version.should == 4
    @conns[0].content_block_version.should == 1

    @conns[1].content_block.should == @block2
    @conns[1].page.should == @page
    @conns[1].page_version.should == 4
    @conns[1].content_block_version.should == 1
    
    @conns[2].content_block.should == @block2
    @conns[2].page.should == @page
    @conns[2].page_version.should == 4
    @conns[2].content_block_version.should == 1
  end
end

describe "Removing a connector from a page" do
  before do
    @page = create_page(:section => root_section)
    @block = create_html_block()
    @conn = @page.add_content_block!(@block, "testing") 
    @destroy_connector = lambda { @page.destroy_connector(@conn) } 
  end
  
  it "should create a new version the page" do
    @destroy_connector.should change(Page::Version, :count).by(1)
  end
  
  it "should should increment the page version by 1" do
    @destroy_connector.should change(@page, :version).by(1)
  end
  
  it "should not alter the original connector" do
    @destroy_connector.call
    conns = Connector.find(:all)
    conns.size.should == 1
    
    conns[0].page.should == @page
    conns[0].page_version.should == 2
    conns[0].content_block.should == @block
    conns[0].content_block_version.should == 1
    
  end
  it "should destroy the connector" do
    @destroy_connector.call
    @page.reload.connectors.should be_empty
  end
  
  it "should return the frozen connector" do
    c = @destroy_connector.call
    c.should be_frozen
    c.should == @conn
  end
end

describe "Removing multiple blocks from a page" do
  before do
    @page = create_page(:section => root_section)
    @block1 = create_html_block()
    @block2 = create_html_block()
    @conn = @page.add_content_block!(@block1, "bar") 
    @conn2 = @page.add_content_block!(@block2, "bar")
    @conn3 = @page.add_content_block!(@block2, "foo")
    #Need to get the new connector that matches @conn2, otherwise you will delete an older version, not the latest connector
    @conn2 = Connector.first(:conditions => {:page_id => @page.reload.id, :page_version => @page.version, :content_block_id => @block2.id, :content_block_version => @block2.version, :container => "bar"})
    @page.destroy_connector(@conn2)
    @destroy_connector = lambda { 
      @conn = Connector.first(:conditions => {:page_id => @page.reload.id, :page_version => @page.version, :content_block_id => @block2.id, :content_block_version => @block2.version, :container => "foo"})
      @page.destroy_connector(@conn) 
    } 
  end
  
  it "should create a new version the page" do
    @destroy_connector.should change(Page::Version, :count).by(1)
  end
  
  it "should have 5 total versions" do
    @destroy_connector.call
    Page::Version.count.should == 6
  end
  it "should should increment the page version by 1" do
    @destroy_connector.should change(@page, :version).by(1)
  end
  
  it "should end up with the correct connectors" do
    
    @destroy_connector.call
    conns = Connector.find(:all, :order => "page_version, content_block_id, container")
    #Rails.logger.info conns.to_table(:id, :page_id, :page_version, :content_block_id, :content_block_version, :container)
    
    conns.size.should == 9
    
    conns[0].should_meet_expectations(:page => @page, :page_version => 2, :content_block => @block1, :content_block_version => 1, :container => "bar")
    conns[1].should_meet_expectations(:page => @page, :page_version => 3, :content_block => @block1, :content_block_version => 1, :container => "bar")
    conns[2].should_meet_expectations(:page => @page, :page_version => 3, :content_block => @block2, :content_block_version => 1, :container => "bar")
    conns[3].should_meet_expectations(:page => @page, :page_version => 4, :content_block => @block1, :content_block_version => 1, :container => "bar")
    conns[4].should_meet_expectations(:page => @page, :page_version => 4, :content_block => @block2, :content_block_version => 1, :container => "bar")
    conns[5].should_meet_expectations(:page => @page, :page_version => 4, :content_block => @block2, :content_block_version => 1, :container => "foo")
    conns[6].should_meet_expectations(:page => @page, :page_version => 5, :content_block => @block1, :content_block_version => 1, :container => "bar")
    conns[7].should_meet_expectations(:page => @page, :page_version => 5, :content_block => @block2, :content_block_version => 1, :container => "foo")
    conns[8].should_meet_expectations(:page => @page, :page_version => 6, :content_block => @block1, :content_block_version => 1, :container => "bar")
   
  end
  it "should destroy one of the connectors" do
    @destroy_connector.call
    @page.reload.connectors.size.should == 1
  end
  
end