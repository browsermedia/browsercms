require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::PagesController do
  include Cms::PathHelper
  
  describe "moving a page" do
    describe "with a valid section id" do
      before do
        login_as_user
        @from_section = create_section(:name => "From", :parent => root_section)
        @to_section = create_section(:name => "To", :parent => root_section)
        @page = create_page(:section => @from_section, :name => "Mover")
        @action = lambda { put :move_to, :id => @page.to_param, :section_id => @to_section.to_param }
      end
      it "should change the section_id of the page to the new section's id" do
        @action.call
        @page.reload.section_id.should == @to_section.id
      end
      it "should set the flash message" do
        @action.call
        flash[:notice].should  == "Page 'Mover' was moved to 'To'."        
      end
      it "should redirect to the section with page_id" do
        @action.call
        response.should redirect_to(cms_url(@to_section, :page_id => @page.to_param))
      end
    end
  end
  
end