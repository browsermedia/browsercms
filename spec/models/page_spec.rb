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
      Page.first(:conditions => {:path => "/"}).should == @page
    end
    it "should be able to find another page" do
      @page = create_page(:path => "about")
      Page.first(:conditions => {:path => "/about"}).should == @page
    end
  end

  describe ".find_live_by_path" do
    before do
      create_page(:name => "Deleted Me", :path => "/test", :section => root_section).destroy
      @page = create_page(:name => "v1", :path => "/test", :section => root_section, :new_status => "PUBLISHED")
      @page = Page.find(@page.id)
      @page.update_attributes!(:name => "v2", :updated_by_user => create_user)
    end
    it "should return the latest version of the page" do
      Page.find_live_by_path("/test").name.should == "v1"
      Page.find_live_by_path("/test").version.should == 1
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

  describe "revision comment" do
    before { @page = create_page(:section => root_section, :name => "V1") }
    it "should be set to 'Created' when the page is created" do
      @page.revision_comment.should == 'Created'
    end
    it "should not be changed if the object is not changed" do
      @page.reload.save
      @page.reload.revision_comment.should == 'Created'
      @page.as_of_version(@page.version).revision_comment.should == 'Created'
    end
    it "should be set to 'Name edited' when the name is changed" do
      @page.update_attributes(:name => "V2")
      @page.revision_comment.should == 'Name edited'
      @page.as_of_version(@page.version).revision_comment.should == 'Name edited'
    end
    it "should be set to 'Html 'Hello, World!' was added to the 'main' container'" do
      @block = create_html_block(:name => "Hello, World!")
      @page.add_content_block!(@block, "main")
      @page.revision_comment.should == "Html 'Hello, World!' was added to the 'main' container"
      @page.as_of_version(@page.version).revision_comment.should == "Html 'Hello, World!' was added to the 'main' container"
    end
    it "should be set to 'HtmlBlock 'Hello, World!' was moved up within the 'main' container'" do
      @block = create_html_block(:name => "Hello, World!")
      @page.add_content_block!(create_html_block(:name => "Whatever"), "main")
      @page.add_content_block!(@block, "main")
      pending "How do we move blocks within containers?"
      @page.revision_comment.should == "HtmlBlock 'Hello, World!' was moved up within the 'main' container"
      @page.as_of_version(@page.version).revision_comment.should == "HtmlBlock 'Hello, World!' was moved up within the 'main' container"
    end
    it "should be set to 'HtmlBlock 'Hello, World!' was moved down within the 'main' container'" do
      @block = create_html_block(:name => "Hello, World!")
      @page.add_content_block!(@block, "main")
      @page.add_content_block!(create_html_block(:name => "Whatever"), "main")
      pending "How do we move blocks within containers?"
      @page.revision_comment.should == "HtmlBlock 'Hello, World!' was moved down within the 'main' container"
      @page.as_of_version(@page.version).revision_comment.should == "HtmlBlock 'Hello, World!' was moved down within the 'main' container"
    end
    it "should be set to 'Html 'Hello, World!' was removed from the 'main' container'" do
      @block = create_html_block(:name => "Hello, World!")      
      @page.destroy_connector(@page.add_content_block!(@block, "main"))
      @page.revision_comment.should == "Html 'Hello, World!' was removed from the 'main' container"
      @page.as_of_version(@page.version).revision_comment.should == "Html 'Hello, World!' was removed from the 'main' container"
    end
    it "should be set to 'Reverted to version 1'" do
      @page.update_attribute(:name, "V2")
      @page.revert_to(1, create_user)
      @page.revision_comment.should == "Reverted to version 1"
      @page.as_of_version(@page.version).revision_comment.should == "Reverted to version 1"
    end    
  end

  describe "status" do
    it "should be in progress when it is created" do
      page = create_page
      page.should be_in_progress
      page.should_not be_published
    end

    it "should be able to be published when creating" do
      page = new_page
      page.publish(create_user).should be_true
      page.should be_published
    end

    it "should be able to be hidden" do
      page = create_page
      page.hide!(create_user)
      page.should be_hidden
    end

    it "should not allow invalid statuses" do
      page = new_page(:new_status => "FAIL")
      page.should have(1).error_on(:status)
    end

    it "should be able to be published" do
      page = create_page(:section => root_section)
      page = Page.find(page.id)
      page.publish(create_user).should be_true  
      page.reload.status.should == "PUBLISHED"
    end
  end

  describe "#container_live?" do
    it "should be true if all blocks are published" do
      page = create_page(:section => root_section)
      page.add_content_block!(create_html_block(:new_status => 'PUBLISHED'), "main")
      page.add_content_block!(create_html_block(:new_status => 'PUBLISHED'), "main")
      page.container_live?("main").should be_true
    end
    it "should be false if there are any non-published blocks" do
      page = create_page(:section => root_section)
      page.add_content_block!(create_html_block(:new_status => 'PUBLISHED'), "main")
      page.add_content_block!(create_html_block(:new_status => 'IN_PROGRESS'), "main")
      page.container_live?("main").should be_false
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
        @delete_page.should_not change(Page, :count_with_deleted)
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
    
    describe "#create_new_version!" do
      before do
        @page = create_page(:section => root_section)
        @increment_version = lambda { @page.create_new_version! }
      end
      it "should increase the version number" do
        @increment_version.call
        @page.reload.version.should == 2
      end
      it "should create a new version" do
        @increment_version.should change(Page::Version, :count).by(1)
      end
    end 
    
    describe "reverting" do
      before do
        @page = create_page(:section => root_section, :name => "V1")
        @page.update_attribute(:name, "V2")
        @revert_the_page = lambda { @page.revert_to(1, create_user)}
      end
      it "should change the version by 1" do
        @revert_the_page.should change(@page, :version).by(1)
      end
      it "should update the attributes" do
        @revert_the_page.call
        @page.name.should == "V1"
      end
    end
  end
end

describe "A page with associated blocks" do
  before do
    @page = create_page(:section => root_section, :name => "Bar")
    @block = create_html_block
    @other_connector = create_connector(:page => create_page(:section => root_section), :content_block => @block)
    @page_connector = create_connector(:page => @page, :content_block => @block)          
    @destroying_the_page = lambda { @page.destroy }
  end
  describe "when updating" do
    describe "with changes" do
      before do
        @updating_the_page = lambda{ @page.update_attribute(:name, "Foo") }
      end
      it "should create new copies of the connectors" do
        @updating_the_page.should change(Connector, :count).by(1)
      end
      it "should change the version by 1" do
        @updating_the_page.should change(@page, :version).by(1)
      end
    end
    describe "without changes" do
      before do
        @updating_the_page = lambda{ @page.update_attribute(:name, "Bar") }
      end
      it "should not create new copies of the connectors" do
        @updating_the_page.should_not change(Connector, :count).by(1)
      end
      it "should not change the version" do
        @updating_the_page.should_not change(@page, :version)
      end
    end
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

describe "A page that had 2 blocks added to it" do
  before do
    @page = create_page(:section => root_section)
    @foo_block = create_html_block(:name => "Foo Block")
    @bar_block = create_html_block(:name => "Bar Block")
    @page.add_content_block!(@foo_block, "whatever")
    @page.reload
    @page.add_content_block!(@bar_block, "whatever")
    @page.reload
  end
  describe "and then had then removed," do
    before do
      @page.destroy_connector(@page.connectors.reload.first(:order => "position"))
      @page.destroy_connector(@page.connectors.reload.first(:order => "position"))      
    end
    describe "when reverting to the previous version," do
      before do
        @reverting_to_the_previous_version = lambda { @page.revert(create_user) }
      end
      it "should restore the connectors from the version being reverted to" do
        @reverting_to_the_previous_version.should change(Connector, :count).by(1)
        @page.connectors.reload.first.should_meet_expectations(:page => @page, :page_version => 6, :content_block => @bar_block, :content_block_version => 1, :container => "whatever")
      end
    end
    describe "when reverting to the version that had both connectors," do
      before do
        @reverting_to_the_previous_version = lambda { @page.revert_to(3, create_user) }
      end
      it "should restore the connectors from version 3" do
        @reverting_to_the_previous_version.should change(Connector, :count).by(2)
        foo, bar = @page.connectors.reload.find(:all, :order => "position")
        foo.should_meet_expectations(:page => @page, :page_version => 6, :content_block => @foo_block, :content_block_version => 1, :container => "whatever")
        bar.should_meet_expectations(:page => @page, :page_version => 6, :content_block => @bar_block, :content_block_version => 1, :container => "whatever")
      end
    end
  end
  describe "and then had one of those block updated," do
    before do
      @foo_block.reload.update_attributes!(:name => "Foo V2")
      @page.reload
    end
    describe "when reverting to a version of the page from before the update to the block," do
      before do
        @reverting_the_page = lambda { @page.revert_to(3, create_user) }
      end
      it "should change the block version from 2 to 3" do
        @foo_block.version.should == 2
        @reverting_the_page.call
        @foo_block.reload.version.should == 3        
      end
      it "should return the block to the state as of the original version" do
        @reverting_the_page.call
        @page.connectors.reload.first.content_block.name.should == "Foo Block"
      end
      it "should change the the page version from 4 to 5" do
        @page.version.should == 4
        @reverting_the_page.call
        @page.version.should == 5
      end
    end
  end
end

describe "Adding a block to a page" do
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
  it "should mark the page as in_progress" do
    @page.publish(create_user)
    @adding_block.call
    @page.status.should == "IN_PROGRESS"
  end
end

describe "Adding a second block to a page" do
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

describe "Adding a third block to a page" do
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
  it "should set the page status to inprogress" do
    @page.publish!(create_user)
    @destroy_connector.call
    @page.status.should == "IN_PROGRESS"
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

describe "A published page" do
  before do
    @user = create_user
    @page = create_page(:section => root_section, :updated_by_user => @user)
    @page.publish!(@user)
    @page = Page.find(@page.id)
  end
  describe "when adding a block by 'save and publish'" do
    before do
      @save_and_publish_the_block = lambda { @block = create_html_block(:connect_to_page_id => @page.id, :new_status => "PUBLISHED", :connect_to_container => "testing", :updated_by_user => @user, :name => "Home") }
    end

    it "should change the connector count by 1" do
      @save_and_publish_the_block.should change(Connector, :count).by(1)
    end

    it "should make the page have one connector" do
      @save_and_publish_the_block.should change(@page.connectors, :count).by(1)
    end

    it "should set the page version to 4" do
      @save_and_publish_the_block.call
      @page.reload.version.should == 3
    end

    it "should set the block version to 2" do
      @save_and_publish_the_block.call
      @block.version.should == 1
    end
    
    it "should set the page status to PUBLISHED" do
      @save_and_publish_the_block.call
      @page.reload.status.should == "PUBLISHED"
    end
  end
  describe "when adding a block by 'save'" do
    before do
      @save_the_block = lambda { @block = create_html_block(:connect_to_page_id => @page.id, :connect_to_container => "testing", :updated_by_user => @user, :name => "Home") }
    end

    it "should change the connector count by 1" do
      @save_the_block.should change(Connector, :count).by(1)
    end

    it "should make the page have one connector" do
      @save_the_block.should change(@page.connectors, :count).by(1)
    end

    it "should set the page version to 4" do
      @save_the_block.call
      @page.reload.version.should == 3
    end

    it "should set the block version to 2" do
      @save_the_block.call
      @block.version.should == 1
    end
    
    it "should not set the page status to PUBLISHED" do
      @save_the_block.call
      @page.reload.status.should_not == "PUBLISHED"
    end
  end

end

describe "When there is a deleted page" do
  before do
    create_page(:section => root_section, :path => "/").destroy    
    @page = new_page(:section => root_section, :path => '/')
  end
  describe "and you create another page with the same path" do
    it "should be valid" do      
      @page.should be_valid      
    end
  end
end

describe "An unpublished page with 1 published and an 1 unpublished block," do
  before do
    @page = create_page(:section => root_section)
    @published_block = create_html_block(:name => "Published")
    @unpublished_block = create_html_block(:name => "Unpublished")
    @page.add_content_block!(@published_block, "main")
    @page.add_content_block!(@unpublished_block, "main")
    log Page::Version.to_table_with(:id, :page_id, :name, :version, :status)
    @published_block.publish!(create_user)
    log Page::Version.to_table_with(:id, :page_id, :name, :version, :status)
    @page.reload
    #log Connector.to_table_without(:created_at, :updated_at)
  end
  describe "when publishing the block" do
    it "the block should be live" do
      @published_block.should be_live
    end
    it "the page should not be live" do
      @page.should_not be_live
    end
  end
  describe "when publishing the page," do
    before { @publishing_the_page = lambda { @page.publish!(create_user) } }
    it "should create a new version of the page" do
      @publishing_the_page.should change(Page::Version, :count).by(1)
    end
    it "should create a new version of the unpublished block" do
      @publishing_the_page.should change(@unpublished_block.versions, :count).by(1)
    end
    it "should not create a new version of the published block" do
      @publishing_the_page.should_not change(@published_block.versions, :count)
    end
    it "the page should be live" do
      @publishing_the_page.call
      @page.should be_live
    end
    it "the unpublished block should be live" do
      @publishing_the_page.call
      @unpublished_block.reload.should be_live
    end
    it "the published block should be live" do
      @publishing_the_page.call
      @published_block.reload.should be_live
    end
    it "the page should be connected to the latest version of the unpublished block" do
      log Page::Version.to_table_with(:id, :page_id, :name, :version, :status)
      @publishing_the_page.call
      log Connector.to_table_without(:created_at, :updated_at)
      log Page.to_table_with(:id, :name, :version, :status)
      log Page::Version.to_table_with(:id, :page_id, :name, :version, :status)
      @page.reload.connectors.last.content_block_version.should == 2
    end
  end
end

describe "Reverting a block that is on multiple pages" do

  it "should revert both pages" do
    #pending "Case 1551"
    
    reset = lambda do 
      @page1 = Page.find(@page1.id)
      @page2 = Page.find(@page2.id)
      @block = HtmlBlock.find(@block.id)
    end

    # 1. Create a new page (Page 1, v1)    
    @page1 = create_page(:section => root_section, :name => "Page 1")
    @page1.version.should == 1
    
    # 2. Create a new page (Page 2, v1)
    @page2 = create_page(:section => root_section, :name => "Page 2")
    
    # 3. Add a new html block to Page 1. Save, don't publish. (Page 1, v2)    
    @block = create_html_block(:name => "Block v1", :connect_to_page_id => @page1.id, :connect_to_container => "main")
    reset.call
    @page1.version.should == 2
    @page2.version.should == 1

    # 4. Goto page 2, and select that block. (Page 2, v2)    
    @page2.add_content_block!(@block, "main")
    reset.call
    @page1.version.should == 2
    @page2.version.should == 2

    # 5. Edit the block (Page 1, v3, Page 2, v3, Block v2)
    @block.update_attributes!(:name => "Block v2", :updated_by_user => create_user)
    reset.call
    @page1.version.should == 3
    @page2.version.should == 3
    @block.version.should == 2
    
    # 6. Revert page 1 to version 2. (Page 1, v4, Page 2, v4, Block v3)
    log Page.to_table_with(:id, :version, :name)
    log HtmlBlock.to_table_with(:id, :version, :name)
    log Connector.to_table_without(:created_at, :updated_at)
    @page1.revert_to(2, create_user)
    log Page.to_table_with(:id, :version, :name)
    log HtmlBlock.to_table_with(:id, :version, :name)
    log Connector.to_table_without(:created_at, :updated_at)
    reset.call
    @page1.version.should == 4
    @page2.version.should == 4
    @block.version.should == 3    
    
    # Expected: Both page 1 and 2 will display the same version of the block (v1).
    @page1.connectors.first.content_block.name.should == "Block v1"
    @page2.connectors.first.content_block.name.should == "Block v1"
    
  end
end

