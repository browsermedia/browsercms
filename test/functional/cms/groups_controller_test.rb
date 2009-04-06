require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::GroupsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    @edit_content = Permission.find_by_name("edit_content")
    @publish_content = Permission.find_by_name("publish_content")
    @random = Factory(:permission, :name => "shouldnt-be-included")
    @group_type = Factory(:group_type, :cms_access => true)
    @public_group_type = Factory(:group_type, :cms_access => false)
    login_as_cms_admin
  end

  def test_create_cms_group
    post :create, :group => Factory.attributes_for(:group, :group_type_id => @group_type.id)
    
    assert_redirected_to :action => "index"    
    
    group = Group.last
    assert_equal 0, group.permissions.count
    assert group.permission_ids.include?(@edit_content.id)
    assert group.permission_ids.include?(@publish_content.id)
  end

  def test_create_cms_group
    post :create, :group => Factory.attributes_for(:group, 
      :group_type_id => @group_type.id,
      :permission_ids => [@edit_content.id.to_s, @publish_content.id.to_s])
    
    assert_redirected_to :action => "index"
    
    group = Group.last
    assert_equal 2, group.permissions.count
    assert group.permission_ids.include?(@edit_content.id)
    assert group.permission_ids.include?(@publish_content.id)
  end

  def test_create_public_group    
    post :create, :group => Factory.attributes_for(:group, :group_type_id => @public_group_type.id)
    
    assert_redirected_to :action => "index"
    
    group = Group.last
    assert_equal 0, group.permissions.count
    assert !group.permission_ids.include?(@edit_content.id)
    assert !group.permission_ids.include?(@publish_content.id)
  end

end
