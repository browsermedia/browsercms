require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::ConnectorsController do
  controller_setup
  
  describe "destroying a connector" do
    before do
      @page = create_page(:section => root_section)
      @block = create_html_block(:connect_to_page_id => @page.id, :connect_to_container => "main")
      @page.reload
      @destroy_connector = lambda { delete :destroy, :id => @page.connectors.first.id }
      
    end
    
    it "should create a new version the page" do      
      @destroy_connector.should change(Page::Version, :count).by(1)
    end
    
    it "should should increment the page version by 1" do
      @page.version.should == 2
      @destroy_connector.call
      @page.reload.version.should == 3
    end
    
    it "should destroy the connector" do
      @destroy_connector.call
      @page.reload.connectors.should be_empty
    end
    
    it "should redirect to the page" do
      @destroy_connector.call
      response.should redirect_to(@page.path)
    end
  end
end