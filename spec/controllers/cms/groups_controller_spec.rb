require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::GroupsController do
  controller_setup

  describe "create" do
    before do
      @edit_content = Permission.find_by_name("edit_content")
      @publish_content = Permission.find_by_name("publish_content")
      @random = create_permission(:name => "shouldnt-be-included")
      @action = lambda { post :create, :group => new_group.attributes }
    end
    it "should redirect to the index" do
      @action.call
      response.should redirect_to(:action => "index")
    end
    it "should add core permissions" do
      @action.call
      group = assigns[:object]
      group.permissions.count.should == 2
      group.permission_ids.include? @edit_content.id
      group.permission_ids.include? @publish_content.id
    end
    it "should fail" do
      @action = lambda { post :create, :on_fail_action => :index, :group => new_group(:name => "").attributes }
      @action.call
      response.should be_success
      response.should have_tag("div#errorExplanation")
    end
  end

end
