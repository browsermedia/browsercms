require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::GroupsController do
  controller_setup

  describe "create" do
    before do
      @edit_content = Permission.find_by_name("edit_content")
      @publish_content = Permission.find_by_name("publish_content")
      @random = create_permission(:name => "shouldnt-be-included")
      @group_type = create_group_type(:cms_access => true)
      @public_group_type = create_group_type(:cms_access => false)
    end
    it "should redirect to the index" do
      post :create, :group => new_group(:group_type_id => @group_type.id).attributes
      response.should redirect_to(:action => "index")
    end
    it "should add core permissions if the group type has cms access" do
      post :create, :group => new_group(:group_type_id => @group_type.id).attributes
      group = assigns[:object]
      group.permissions.count.should == 2
      group.permission_ids.should include(@edit_content.id)
      group.permission_ids.should include(@publish_content.id)
    end
    it "should not add core permissions if the group type does not have cms access" do
      post :create, :group => new_group(:group_type_id => @public_group_type.id).attributes
      group = assigns[:object]
      group.permissions.count.should == 0
      group.permission_ids.should_not include(@edit_content.id)
      group.permission_ids.should_not include(@publish_content.id)
    end
    it "should fail" do
      post :create, :on_fail_action => :index, :group => new_group(:name => "").attributes
      response.should be_success
      response.should have_tag("div#errorExplanation")
    end
  end

end
