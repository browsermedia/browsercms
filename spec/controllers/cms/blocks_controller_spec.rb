require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::BlocksController do
  controller_setup
  before(:each) do
    create_content_type(:name => "HtmlBlock")
  end

  describe "creating a block that should be connected to a page" do
    before do
      @page = create_page(:path => "/test", :section => root_section)
      @action = lambda { post :create, :html_block => new_html_block.attributes.merge({:connect_to_page_id => @page.id, :connect_to_container => "test"}) }
    end
    it "should create the block" do
      @action.should change(HtmlBlock, :count).by(1)
    end
    it "should create the connector" do
      @action.call
      @page.reload.connectors.first.container.should == "test"
    end
    it "should redirect to the page" do
      @action.call
      response.should redirect_to(@page.path)
    end
  end

  describe "showing a block" do
    before do
      @block = create_html_block(:name => "Test", :content => "I worked.")
      @action = lambda { get :show, :id => @block.id }
    end
    it "should be success" do
      @action.call
      response.should be_success
    end

    it "should render block html body as content " do
      @action.call
      response.should have_tag("div.content", "I worked.")
    end
    it "should have link to revisions" do
      @action.call
      response.should have_tag("a", "Revisions")
    end
  end

  describe "list blocks" do
    before(:each) do
      root_section
      @block = create_html_block(:name => "Test", :content => "I worked.")
      @action = lambda { put :index }
    end
    it "should be successful" do
      @action.call
      response.should be_success
    end

    it "should list the blocks's name" do
      @action.call
      response.should have_tag("td.block_name", "Test")
    end

    it "should show the status of each block" do
      @action.call
      response.should have_tag("td.block_status")  do
        with_tag("img[alt=?]", "Draft")
      end
    end
  end

  describe "searching blocks" do
    before(:each) do
      root_section
      @block = create_html_block(:name => "Test", :content => "I worked.")
    end
    it "should list the search results" do
      get :index, :search => {:term => 'test'}
      response.should have_tag("td.block_name", "Test")
    end
    it "should include the content in the search" do
      get :index, :search => {:term => 'worked', :include_body => true }
      response.should have_tag("td.block_name", "Test")
    end
    it "should not list any results with a bad search term" do
      get :index, :search => {:term => 'invalid'}
      response.should_not have_tag("td.block_name", "Test")
    end
    describe "which are file blocks" do
      before do
        @file = mock_file(:read => "This is a test")
        create_content_type(:name => "FileBlock")
        @file_block = create_file_block(:section => root_section, :attachment_file => @file, :attachment_file_name => "/test.txt", :name => "Test File", :publish_on_save => true)
        @foo_section = create_section(:name => "Foo", :parent => root_section)
      end
      it "should find a file in the section specified" do
        get :index, :block_type => 'file_block', :section_id => root_section.id
        response.should have_tag("td.block_name", "Test File")
      end
      it "should not find a file if it's in another section" do
        get :index, :block_type => 'file_block', :section_id => @foo_section.id
        response.should_not have_tag("td.block_name", "Test File")
      end
      it "should find a file when searching all sections" do
        get :index, :block_type => 'file_block', :section_id => 'all'
        response.should have_tag("td.block_name", "Test File")
      end
    end
  end

  describe "edit a block" do
    before do
      @block = create_html_block(:name => "Test")
      @action = lambda { get :edit, :id => @block.id }
    end

    it "should be successful" do
      @action.call
      response.should be_success
    end

    it "should load block and display form with fields loaded" do
      @action.call
      response.should have_tag("input[id=?][value=?]", "html_block_name", "Test")
    end
  end


  describe "updates to a block" do
    before do
      @block = create_html_block(:name => "V1")
      @action = lambda { put :update, :id => @block.id, :html_block => {:name => "V2"} }
    end
    it "should create a new version of the block" do
      @action.should change(HtmlBlock::Version, :count).by(1)
    end
    it "should not create a new record in the block table" do
      @action.should_not change(HtmlBlock, :count)
    end
    it "should change the attributes of the block" do
      @action.call
      @block.reload.name.should == "V2"
    end
    it "should not change the attributes of previous versions of the block" do
      @action.call
      @block.as_of_version(1).name.should == "V1"
    end
    it "should set the flash message" do
      @action.call
      flash[:notice].should == "Html Block 'V2' was updated"
    end
    it "should redirect to the block" do
      @action.call
      response.should redirect_to(cms_url(@block))
    end
  end

  describe "publish" do
    before do
      @block = create_html_block
      @action = lambda { post :publish, :id => @block.id }
    end
    it "should be redirect" do
      @action.call
      response.should be_redirect
    end
    it "should be able to update the status of a block" do
      @block.published?.should be_false
      @action.call
      @block.reload.published?.should be_true
    end
    it "should redirect to the block show action" do
      @action.call
      response.should redirect_to(cms_url(@block))
    end
  end
  describe "list revisions" do
    before(:each) do
      @block = create_html_block(:name => "V1")
      @action = lambda { get :revisions, :id => @block.id }
    end
    it "should assign the block" do
      @action.call
      assigns[:block].should == @block
    end
    it "should be success" do
      @action.call
      response.should be_success
    end
  end
  describe "revert_to" do
    before do
      @block = create_html_block(:name => "V1")
      @block.update_attributes(:name => "V2")
    end
    describe "with a valid version" do
      before do
        @action = lambda { reset(:block); post :revert_to, :id => @block.id, :version => "1"; reset(:block) }
      end
      it "should create a new version of the block" do
        @action.call
        @block.version.should == 3
      end
      it "should set the name of the block to the original name" do
        @action.call
        @block.reload.name.should == "V1"
      end
      it "should set the flash message" do
        @action.call
        flash[:notice].should == "Reverted 'V1' to version 1"
      end
      it "should redirect to the block show action" do
        @action.call
        response.should redirect_to(cms_url(@block))
      end
    end
    describe "without a version parameter" do
      before do
        @action = lambda { reset(:block); post :revert_to, :id => @block; reset(:block) }
      end
      it "should not create a new version of the block" do
        @action.should_not change(HtmlBlock::Version, :count)
      end
      it "should set the flash error message" do
        @action.call
        flash[:error].should == "Could not revert 'V2': Version parameter missing"
      end
      it "should redirect to the block show action" do
        @action.call
        response.should redirect_to(cms_url(@block))
      end
    end
    describe "with an invalid version parameter" do
      before do
        @action = lambda { post :revert_to, :id => @block, :version => 99}
      end
      it "should not create a new version of the block" do
        @action.should_not change(HtmlBlock::Version, :count)
      end
      it "should set the flash error message" do
        @action.call
        flash[:error].should == "Could not revert 'V2': Could not find version 99"
      end
      it "should redirect to the block show action" do
        @action.call
        response.should redirect_to(cms_url(@block))
      end
    end
  end

  it "should route to block controller based on block type in URL" do
    params_from(:get, '/cms/blocks/html_block/show/1').should == {:controller => 'cms/blocks', :action=>'show', :id => '1', :block_type=>'html_block'}
  end

  describe "CRUD actions based on standard models (HtmlBlock)" do
    before(:each) do
      create_content_type(:name => "HtmlBlock")
    end

    describe "getting the form to create a new block from an existing page" do
      before do
        @page = create_page(:path => "/test", :section => root_section)
        @action = lambda { get :new, :html_block => {:connect_to_page_id => @page.id, :connect_to_container => "test"} }
      end
      it "should have a hidden input with the connect_to_page_id set" do
        @action.call
        response.should have_tag("input[name=?][value=?]", "html_block[connect_to_page_id]", @page.id.to_s)
      end
      it "should have a hidden input with the connect_to_container set" do
        @action.call
        response.should have_tag("input[name=?][value=?]", "html_block[connect_to_container]", "test")
      end
    end

    describe "creating a new object on its own" do
      before(:each) do
        @action = lambda { get :new,  :block_type => "html_blocks"}
      end

      it "should have the correct test setup (i.e. have HtmlBlocks in the db as a ContentType)" do
        ContentType.find_by_key("html_block").should_not == nil
      end

      it "should call standard /new for normal blocks" do
        @action.call
        response.should have_tag("h2", "New Text")
      end
    end
  end

  describe "CRUD for image files" do
    before(:each) do
      create_content_type(:name => "ImageBlock")
    end
    describe "adding new content" do
      before(:each) do
        @action = lambda { get :new,  :block_type => "image_blocks"}
      end

      it "should be using image_blocks content_type" do
        @action.call
        @controller.send(:model_name).should == "image_block"
      end

      it "should call standard /new for normal blocks" do
        @action.call
        response.should have_tag("h2", "New Image")
      end
    end
    describe "editing content" do
      before(:each) do
        @image = create_image_block(:section => root_section, :attachment_file => mock_file, :attachment_file_name => "test.jpg")
        @action = lambda { get :edit,  :block_type => "image_blocks", :id => @image.id}
      end

      it "should be using image_blocks content_type" do
        @action.call
        @controller.send(:model_name).should == "image_block"
      end

      it "should call standard /edit for normal blocks" do
        @action.call
        assigns[:block].section_id.should == root_section.id
        response.should have_tag("h2", "Edit #{@image.name}")
        response.should have_tag("select[name=?]", "image_block[section_id]") do
          with_tag("option[value=?][selected=?]", root_section.id, "selected")
        end
      end

    end
    describe "updating content" do
      before(:each) do
        @image = create_image_block(:section => root_section, :attachment_file => mock_file, :attachment_file_name => "test.jpg")
        @other_section = create_section(:parent => root_section, :name => "Other")
        @action = lambda { put :update, :block_type => "image_blocks", :id => @image.id, :image_block => {:section_id => @other_section.id} }
      end

      it "should move images to a new section" do
        @action.call
        @image = ImageBlock.find(@image.id)
        @image.section.should == @other_section
      end
    end
  end

  describe "CRUD for Portlets (which have custom page flow)" do
    before(:each) do
      create_content_type(:name => "Portlet")
      @block = create_dynamic_portlet(:name => "V1", :code => "@foo = 42", :template => "<%= @foo %>")
    end

    describe "show" do
      before(:each) do
        @action = lambda { get :show, :id => @block.id, :block_type => "portlets" }
      end
      it "should be success" do
        @action.call
        response.should be_success
      end
      it "should disable revisions (as portlets are not versionable" do
        @action.call
        response.should_not have_tag("a#revisions_link")
      end
    end

    describe "revisioning" do
      it "should return Not Implemented" do
        get :revisions, :id => @block.id, :block_type => "portlets"
        response.code.should == "501"
      end
    end

    describe "adding new content" do
      before(:each) do
        @action = lambda { get :new,  :block_type => "portlet"}
      end

      it "should have the correct test setup (i.e. have HtmlBlocks in the db as a ContentType)" do
        ContentType.find_by_key("portlet").should_not == nil
      end

      it "should be using portlet content_type" do
        @action.call
        @controller.send(:model_name).should == "portlet"
      end

      it "should render custom view for /new" do
        @action.call
        response.should have_tag("title", "Content Library / Select Portlet Type")
      end
    end

    describe "edit a block" do
      before do
        @action = lambda { get :edit, :id => @block.id, :block_type => "portlets" }
      end

      it "should be successful" do
        @action.call
        response.should be_success
      end

      it "should render the correct template for editing a portlet" do
        @action.call
        response.should have_tag("h2", "Edit V1")
      end
    end

    describe "destroying" do
      it "should remove the row" do
        delete :destroy, :id => @block.id, :block_type => "portlet"
        lambda { Portlet.find(@block.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end