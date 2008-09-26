require File.dirname(__FILE__) + '/../../spec_helper'

describe Cms::PortletsController do
  controller_setup

  describe "when rendering custom form for new" do
    before(:each) do
      @portlet_type = create_portlet_type
      create_content_type(:name => "Portlet")
      @action = lambda { get :new, :portlet_type_id => @portlet_type.id }
    end

    it "should be successful" do
      @action.call
      response.should be_success
    end

    it "should render form with link to BlocksController#create" do
      @action.call
      Rails.logger.info response.body
      response.should have_tag("form.new_portlet[action=?]", "/cms/blocks/portlet/create/")
    end
  end

end