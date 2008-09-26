require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::BlocksController do
  controller_setup
  before(:each) do
    create_content_type(:name => "HtmlBlock")
  end

  describe "#model_name" do
    describe "with no last_block_type or block_type parameter" do
      before do
        @controller.stub!(:session).and_return({})
        @controller.stub!(:params).and_return({})
      end
      it "should return 'html_block' and set the last_block_type" do
        @controller.send(:model_name).should == "html_block"
        @controller.session[:last_block_type].should == "html_block"
      end
    end
    describe "with no last_block_type and block_type parameter of 'foo" do
      before do
        @controller.stub!(:session).and_return({})
        @controller.stub!(:params).and_return({:block_type => "foo"})
      end
      it "should return 'foo' and set the last_block_type" do
        @controller.send(:model_name).should == "foo"
        @controller.session[:last_block_type].should == "foo"
      end
    end
    describe "with last_block_type of 'bar' and block_type parameter of 'foo'" do
      before do
        @controller.stub!(:session).and_return({:last_block_type => "bar"})
        @controller.stub!(:params).and_return({:block_type => "foo"})
      end
      it "should return 'foo' and set the last_block_type" do
        @controller.send(:model_name).should == "foo"
        @controller.session[:last_block_type].should == "foo"
      end
    end
    describe "with last_block_type of 'bar' and no block_type parameter" do
      before do
        @controller.stub!(:session).and_return({:last_block_type => "bar"})
        @controller.stub!(:params).and_return({})
      end
      it "should return 'foo' and set the last_block_type" do
        @controller.send(:model_name).should == "bar"
        @controller.session[:last_block_type].should == "bar"
      end
    end
    describe "with block_type parameter of html_blocks" do
      before do
        @controller.stub!(:params).and_return({:block_type => "html_blocks"})
      end
      it "should return 'html_block' for the model_name" do
        @controller.send(:model_name).should == "html_block"
        @controller.session[:last_block_type].should == "html_block"
      end
    end
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
      @action = lambda { put :show, :id => @block.id }
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
      response.should have_tag("a#revisions_link")
    end
  end

  describe "list blocks" do
    before(:each) do
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
    it "should be success" do
      @action.call
      response.should be_success
    end
  end
  describe "revert_to" do
    before do
      @block = create_html_block(:name => "V1")
      @block.update_attribute(:name, "V2")
    end
    describe "with a valid version" do
      before do
        @action = lambda { post :revert_to, :id => @block.id, :version => "1" }
      end
      it "should create a new version of the block" do
        @action.call
        @block.reload.version.should == 3
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
        @action = lambda { post :revert_to, :id => @block}
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
        response.should have_tag("h2", "New Html")
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
        @image = create_image_block(:section => root_section, :file => mock_file)
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
        @image = create_image_block(:section => root_section, :file => mock_file)
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
      @block = create_portlet(:name => "V1")
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
        pending 'Make the BlockController#revisions return a response code of 501 rather than throwing an exception'
        @action = lambda { get :revisions, :id => @block.id, :block_type => "portlets" }
        response.should == "501" # Http 'Not Implemented'
      end
    end

    describe "adding new content" do
      before(:each) do
        @action = lambda { get :new,  :block_type => "portlets"}
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
        response.should have_tag("h1", "Select Portlet Type")
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
        response.should have_tag("h2", "Edit Portlet")
      end
    end

    describe "destroying" do
      before(:each) do
        @action = lambda { delete :destroy, :id => @block.id, :block_type => "portlets" }
      end
      it "should remove the row" do
        @action.call
        delete = lambda {Portlet.find(@block.id)}
        delete.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end