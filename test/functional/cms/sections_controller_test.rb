require 'test_helper'

module Cms
class SectionsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    given_a_site_exists
    login_as_cms_admin
    given_there_is_a_sitemap
  end
  
  test "GET new should set the groups to the parent section's groups by default" do
    @group = create(:group, :name => "Test", :group_type => create(:group_type, :name => "CMS User", :cms_access => true))
    get :new, :section_id => root_section.to_param

    assert_response :success
    expected_groups = root_section.groups
    assert_equal expected_groups, assigns(:section).groups
    assert !assigns(:section).groups.include?(@group)
  end
  
  def test_update
    @section = create(:section, :name => "V1", :parent => root_section, :groups => root_section.groups)
    
    put :update, :id => @section.to_param, :section => {:name => "V2"}
    reset(:section)
    
    assert_redirected_to @section
    assert_equal "V2", @section.name
    assert_equal "Section 'V2' was updated", flash[:notice]
  end  
  
end

class SectionsControllerPermissionsTest < ActionController::TestCase
  tests Cms::SectionsController
  include Cms::ControllerTestHelper
  
  def setup
    # DRYME copypaste from UserPermissionTest
    @user = create(:user)
    #@group = @user.groups.first
    @group = create(:group, :name => "Test", :group_type => create(:group_type, :name => "CMS User", :cms_access => true))
    @group.permissions << create_or_find_permission_named("edit_content")
    @group.permissions << create_or_find_permission_named("publish_content")
    @user.groups << @group
    
    @editable_section = create(:section, :parent => root_section, :name => "Editable")
    @editable_subsection = create(:section, :parent => @editable_section, :name => "Editable Subsection")
    @group.sections << @editable_section
    @editable_page = create(:page, :section => @editable_section, :name => "Editable Page")
    @editable_subpage = create(:page, :section => @editable_subsection, :name => "Editable SubPage")
    @editable_link = create(:link, :section => @editable_section, :name => "Editable Link")
    @editable_sublink = create(:link, :section => @editable_subsection, :name => "Editable SubLink")
    
    @noneditable_section = create(:section, :parent => root_section, :name => "Not Editable")
    @noneditable_page = create(:page, :section => @noneditable_section, :name => "Non-Editable Page")
    @noneditable_link = create(:link, :section => @noneditable_section, :name => "Non-Editable Link")
    
    @noneditables = [@noneditable_section, @noneditable_page, @noneditable_link]
    @editables = [@editable_section, @editable_subsection, 
      @editable_page, @editable_subpage, 
      @editable_link, @editable_sublink]

  end

  def test_new_permissions
    login_as(@user)

    get :new, :section_id => @editable_section
    assert_response :success

    get :new, :section_id => @noneditable_section
    assert_response 403
    assert_template "cms/shared/access_denied"
  end
  
  test "POST create should set the groups to the parent section's groups for non-admin user" do
    @group = create(:group, :name => "Test", :group_type => create(:group_type, :name => "CMS User", :cms_access => true))
    login_as(@user)
    get :new, :section_id => @editable_section
    assert_equal @editable_section.groups, assigns(:section).groups
    assert !assigns(:section).groups.include?(@group)
  end

  def test_create_permissions
    login_as(@user)

    post :create, :section_id => @editable_section, :name => "Another editable subsection"
    assert_response :success

    post :create, :section_id => @noneditable_section, :name => "Another non-editable subsection"
    assert_response 403
    assert_template "cms/shared/access_denied"
  end

  def test_edit_permissions
    login_as(@user)

    get :edit, :id => @editable_section
    assert_response :success

    get :edit, :id => @noneditable_section
    assert_response 403
    assert_template "cms/shared/access_denied"
  end

  def test_update_permissions
    login_as(@user)

    put :update, :id => @editable_section, :name => "Modified editable subsection"
    assert_response :redirect

    put :update, :id => @noneditable_section, :name => "Modified non-editable subsection"
    assert_response 403
    assert_template "cms/shared/access_denied"
  end
  
  def test_update_permissions_of_subsection
    login_as(@user)

    put :update, :id => @editable_section, :name => "Modified editable subsection"
    assert_response :redirect

    put :update, :id => @editable_subsection, :name => "Section below editable section"
    assert_response 403
    assert_template "cms/shared/access_denied"
  end
  
  test "PUT update should leave groups alone for non-admin user" do
    @group2 = create(:group, :name => "Test", :group_type => create(:group_type, :name => "CMS User", :cms_access => true))
    expected_groups = @editable_section.groups
    login_as(@user)
    put :update, :id => @editable_section
    assert_response :redirect
    assert_equal expected_groups, assigns(:section).groups
    assert !assigns(:section).groups.include?(@group2)
  end

  test "PUT update should leave groups alone for non-admin user even if hack url" do
    @group2 = create(:group, :name => "Test", :group_type => create(:group_type, :name => "CMS User", :cms_access => true))
    expected_groups = @editable_section.groups
    login_as(@user)
    put :update, :id => @editable_section, :section => {:name => "new name", :group_ids => [@group.id, @group2.id]}

    assert_response :redirect
    assert_equal expected_groups, assigns(:section).groups
    assert_equal "new name", assigns(:section).name
    assert !assigns(:section).groups.include?(@group2)
  end



  test "PUT update should add groups for admin user" do
    @user.groups.first.sections <<  @editable_subsection
    @group2 = create(:cms_user_group)
    expected_groups = [@group, @group2]
    login_as_cms_admin
    put :update, :id => @editable_subsection, :cms_section => {:name => "new name", :group_ids => [@group.id, @group2.id]}
    assert_response :redirect
  end

  def test_destroy_permissions
    login_as(@user)

    delete :destroy, :id => @editable_section
    assert_response :redirect

    delete :destroy, :id => @noneditable_section
    assert_response 403
    assert_template "cms/shared/access_denied"
  end
end
end
