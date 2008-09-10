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
      before do
        @page = create_page
        @delete_page = lambda { @page.delete! }
      end
      
      it "should not actually delete the row" do
        @delete_page.should_not change(Page, :count)
      end
      it "should create a new version" do
        @delete_page.should change(@page.versions, :count).by(1)
      end
      it "should set the status to DELETED" do
        @delete_page.call
        @page.should be_deleted
      end
    end
    
  end
  
end
