require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::SectionsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
  end
  
  def test_edit
    get :edit, :id => root_section.to_param
    assert_response :success
    assert_select "input[name=?][value=?]", "section[name]", root_section.name
  end
  
  test "GET new should set the groups to the parent section's groups by default" do
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    get :new, :section_id => root_section.to_param
    assert_equal root_section.groups, assigns(:section).groups
    assert !assigns(:section).groups.include?(@group)
  end
  
  def test_update
    @section = Factory(:section, :name => "V1", :parent => root_section, :groups => root_section.groups)
    
    put :update, :id => @section.to_param, :section => {:name => "V2"}
    reset(:section)
    
    assert_redirected_to [:cms, @section]
    assert_equal "V2", @section.name
    assert_equal "Section 'V2' was updated", flash[:notice]
  end  
  
end

class Cms::SectionFileBrowserControllerTest < ActionController::TestCase
  tests Cms::SectionsController
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
  end
  
  def test_root_section
    @foo = Factory(:section, :parent => root_section, :name => "Foo", :path => '/foo')
    @bar = Factory(:section, :parent => root_section, :name => "Bar", :path => '/bar')
    @home = Factory(:page, :section => root_section, :name => "Home", :path => '/home')

    get :file_browser, :format => "xml", "CurrentFolder" => "/", "Command" => "GetFilesAndFolders", "Type" => "Page"

    assert_response :success
    assert_equal "text/xml", @response.content_type
    assert_select "Connector[command=?][resourceType=?]", "GetFilesAndFolders", "Page" do
      assert_select "CurrentFolder[path=?][url=?]", "/", "/"
      assert_select "Folders" do
        assert_select "Folder[name=?]", "Foo"
        assert_select "Folder[name=?]", "Bar"
      end
      assert_select "Files" do
        assert_select "File[name=?][url=?][size=?]", "Home", "/home", "?"
      end
    end
  end
  
  def test_sub_section
    @foo = Factory(:section, :parent => root_section, :name => "Foo", :path => '/foo')
    @bar = Factory(:section, :parent => @foo, :name => "Bar", :path => '/foo/bar')
    @foo_page = Factory(:page, :section => @foo, :name => "Foo Page", :path => '/foo/page')
    @home = Factory(:page, :section => root_section, :name => "Home", :path => '/home')
    get :file_browser, :format => "xml", "CurrentFolder" => "/Foo/", "Command" => "GetFilesAndFolders", "Type" => "Page"

    assert_response :success
    assert_equal "text/xml", @response.content_type
    assert_select "Connector[command=?][resourceType=?]", "GetFilesAndFolders", "Page" do
      assert_select "CurrentFolder[path=?][url=?]", "/Foo/", "/Foo/"
      assert_select "Folders" do
        assert_select "Folder[name=?]", "Bar"
      end
      assert_select "Files" do
        assert_select "File[name=?][url=?][size=?]", "Foo Page", "/foo/page", "?"
      end
    end
  end
  
end

class Cms::SectionsControllerPermissionsTest < ActionController::TestCase
  tests Cms::SectionsController
  include Cms::ControllerTestHelper
  
  def setup
    # DRYME copypaste from UserPermissionTest
    @user = Factory(:user)
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @group.permissions << create_or_find_permission_named("edit_content")
    @group.permissions << create_or_find_permission_named("publish_content")
    @user.groups << @group
    
    @editable_section = Factory(:section, :parent => root_section, :name => "Editable")
    @editable_subsection = Factory(:section, :parent => @editable_section, :name => "Editable Subsection")
    @group.sections << @editable_section
    @editable_page = Factory(:page, :section => @editable_section, :name => "Editable Page")
    @editable_subpage = Factory(:page, :section => @editable_subsection, :name => "Editable SubPage")
    @editable_link = Factory(:link, :section => @editable_section, :name => "Editable Link")
    @editable_sublink = Factory(:link, :section => @editable_subsection, :name => "Editable SubLink")
    
    @noneditable_section = Factory(:section, :parent => root_section, :name => "Not Editable")
    @noneditable_page = Factory(:page, :section => @noneditable_section, :name => "Non-Editable Page")
    @noneditable_link = Factory(:link, :section => @noneditable_section, :name => "Non-Editable Link")
    
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
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
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
    @group2 = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    expected_groups = @editable_section.groups
    login_as(@user)
    put :update, :id => @editable_section
    assert_response :redirect
    assert_equal expected_groups, assigns(:section).groups
    assert !assigns(:section).groups.include?(@group2)
  end

  test "PUT update should leave groups alone for non-admin user even if hack url" do
    @group2 = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    expected_groups = @editable_section.groups
    login_as(@user)
    RAILS_DEFAULT_LOGGER.warn("starting...")
    put :update, :id => @editable_section, :section => {:name => "new name", :group_ids => [@group, @group2]}
    assert_response :redirect
    assert_equal expected_groups, assigns(:section).groups
    assert_equal "new name", assigns(:section).name
    assert !assigns(:section).groups.include?(@group2)
  end



  test "PUT update should add groups for admin user" do
# This step is unnecessary in the actual cms, as you can't stop the admin from doing anything
    Group.find(:first, :conditions => "code = 'cms-admin'").sections << @editable_subsection
    @group2 = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    expected_groups = [@group, @group2]
    login_as_cms_admin
    put :update, :id => @editable_subsection, :section => {:name => "new name", :group_ids => [@group, @group2]}
    assert_response :redirect
    assert_equal expected_groups, assigns(:section).groups
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
