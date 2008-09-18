require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Page do
  it "should validate uniqueness of path" do
    root = create_section
    create_page(:path => "test", :section => root)
    page = new_page(:path => "test", :section => root)
    page.should_not be_valid
    page.should have(1).error_on(:path)
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
    page.move_to(section)
    page.section.should == section
  end

  describe "move_to" do
    before do
      @from_section = create_section(:name => "From", :parent => root_section)
      @to_section = create_section(:name => "To", :parent => root_section)
      @page = create_page(:section => @from_section, :name => "Mover")
      @action = lambda { @page.move_to(@to_section) }
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
          @page = create_page(:name => "Original Value")
          @page.update_attributes(:name => "Something Different")
        end
        it "should create a version with the changed values" do
          @page.versions.latest.page.should == @page
          @page.versions.latest.name.should == "Something Different"
          @page.name.should == "Something Different"
        end
        it "should not affect the values in previous versions" do
          @page.versions.first.name.should == "Original Value"
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
    it "should do what it does (TBD)"
  end
end


