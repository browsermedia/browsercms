require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::GroupsController do
  controller_setup

  describe "create" do
    before do
      @group = new_group
      @editor = create_permission(:name => "editor")
      @publisher = create_permission(:name => "publish-page")
      @random = create_permission(:name => "shouldnt-be-included")
      @action = lambda { post :create, :group => @group.attributes }
    end
    it "should not fail" do
      @action.call
      response.should be_redirect 
      response.should redirect_to(:action => "index")
    end
    it "should add core permissions" do
      @action.call
      group = Group.first
      group.permissions.count.should == 2
      group.permission_ids.include? @editor.id
      group.permission_ids.include? @publisher.id
    end
    it "should fail" do
      @action = lambda { post :create, :on_fail_action => :index, :group => @group.attributes.merge(:name => "") }
      @action.call
      response.should be_success
      response.should have_tag("div#errorExplanation")
    end
  end

end
