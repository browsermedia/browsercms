require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::ContentTypesController do
  include Cms::PathHelper
  integrate_views
  
  describe "select" do
    before do
      @html_block = create_content_type(:name => "HtmlBlock")
      @page = create_page(:section => root_section)
      @container = "foo"
      login_as_user
    end
    it "should contain links to create a new block" do
      get :select, :connect_to_page_id => @page.to_param, :connect_to_container => @container
      log response.body
      
      response.should have_tag("a[href=?]", cms_path(:blocks, :html_blocks, :new, 
        "html_block[connect_to_container]" => @container,
        "html_block[connect_to_page_id]" => @page).gsub(/&/,'&amp;'), @html_block.display_name)
    end
  end
  
end

