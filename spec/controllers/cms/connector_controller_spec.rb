require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::ConnectorsController do
  controller_setup

  describe "destroying a connector" do
    before do
      @page = create_page(:section => root_section)
      @block = create_html_block(:connect_to_page_id => @page.id, :connect_to_container => "main")
      @page.reload
      @remove_connector = lambda { delete :destroy, :id => @page.connectors.for_page_version(@page.version).first.id }

    end

    it "should create a new version the page" do
      @remove_connector.should change(Page::Version, :count).by(1)
    end

    it "should should increment the page version by 1" do
      @page.version.should == 2
      @remove_connector.call
      @page.reload.version.should == 3
    end

    it "should destroy the connector" do
      @remove_connector.call
      @page.reload.connectors.for_page_version(@page.version).should be_empty
    end

    it "should redirect to the page" do
      @remove_connector.call
      response.should redirect_to(@page.path)
    end
  end

  describe "usages" do
    before(:each) do
      @page = create_page(:section => root_section, :name => "Included")
      @page2 = create_page(:section => root_section, :path => "/other_path", :name => "Excluded")
      @block = create_html_block(:connect_to_page_id => @page.id, :connect_to_container => "main")
      @action = lambda { get :usages, :id => @block.id, :block_type => "html_block"}

      register_type(HtmlBlock)
    end

    it "should be successful" do
      @action.call
      response.should be_success
    end

    it "should list the usages of the block" do
      @action.call
      response.should have_tag("h2", "View Usages")
    end

    it "should contain the correct pages" do
      @action.call
      response.should have_tag("td.page_name", "Included")
      response.should_not have_tag("td.page_name", "Excluded")
    end

    it "should have block toolbar, including the List All link." do
      @action.call
      response.should have_tag("a#list_all")
    end

    it "should have block side menu" do
      @action.call
      response.should have_tag("h3#content_types", "Content Types")
    end

    it "should have file info panel" do
      @action.call
      response.should have_tag("h2#file_information", "File Information")
    end
  end
end