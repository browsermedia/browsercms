require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::PagesControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    login_as_cms_admin
  end

  def test_new
    get :new, :section_id => root_section.id
    assert_response :success
    assert_equal root_section, assigns(:page).section
  end

  def test_edit
    create_page
    
    # Make a change to the page, unpublished
    @page.update_attributes(:name => "V2")
    
    get :edit, :id => @page.id
    assert_response :success
    assert_select "#page_name[value=?]", "V2"
  end

  def test_unhide

    create_page
    
    @page.update_attributes(:hidden => true)
    reset(:page)
    
    assert @page.draft.hidden?
    
    put :update, :id => @page.id, :page => {:hidden => false}
    assert_redirected_to [:cms, @page]
    
    reset(:page)
    assert !@page.draft.hidden?
  end

  def test_publish
    create_page
    
    assert !@page.published?
    
    put :publish, :id => @page.to_param
    reset(:page)

    assert @page.published?
    assert_equal "Page 'Test' was published", flash[:notice]
    
    assert_redirected_to @page.path
  end

  def test_versions
    create_page
    @page.update_attributes(:name => "V2")
    @page.update_attributes(:name => "V3")
    
    get :versions, :id => @page.to_param
    #log @response.body
    (1..3).each do |n|
      assert_select "tr[id=?]", "revision_#{n}"
    end
  end

 def test_version
    create_page
    @page.update_attributes(:name => "V2")
    get :version, :id => @page.to_param, :version => 1
    assert_response :success
  end

  def test_revert_to
    create_page
    @page.update_attributes(:name => "V2")
    @page.update_attributes(:name => "V3")      
    reset(:page)
    
    put :revert_to, :id => @page.to_param, :version => 1
    reset(:page)
  
    assert_redirected_to @page.path
    assert !@page.published?
    assert_equal "Test", @page.name
    assert_equal 4, @page.draft.version
  end

  protected
    def create_page
      @page = Factory(:page, :section => root_section, :name => "Test", :path => "test")      
    end

end

class Cms::PagesControllerPermissionsTest < ActionController::TestCase
  tests Cms::PagesController
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

  def test_create_permissions
    login_as(@user)

    post :create, :section_id => @editable_section, :name => "Another editable page"
    assert_response :success

    post :create, :section_id => @noneditable_section, :name => "Another non-editable page"
    assert_response 403
    assert_template "cms/shared/access_denied"
  end

  def test_edit_permissions
    login_as(@user)

    get :edit, :id => @editable_page
    assert_response :success

    get :edit, :id => @noneditable_page
    assert_response 403
    assert_template "cms/shared/access_denied"
  end

  def test_update_permissions
    login_as(@user)

    # Regular update
    put :update, :id => @editable_page, :name => "Modified editable page"
    assert_response :redirect

    put :update, :id => @noneditable_page, :name => "Modified non-editable page"
    assert_response 403
    assert_template "cms/shared/access_denied"

    # archive
    put :archive, :id => @editable_page
    assert_response :redirect

    put :archive, :id => @noneditable_page
    assert_response 403
    assert_template "cms/shared/access_denied"

    # hide
    put :hide, :id => @editable_page
    assert_response :redirect

    put :hide, :id => @noneditable_page
    assert_response 403
    assert_template "cms/shared/access_denied"

    # publish
    put :publish, :id => @editable_page
    assert_response :redirect

    put :publish, :id => @noneditable_page
    assert_response 403
    assert_template "cms/shared/access_denied"

    # publish many
    put :publish, :page_ids => [@editable_page.id]
    assert_response :redirect
    
    put :publish, :page_ids => [@noneditable_page.id]
    assert_response 403
    
    put :publish, :page_ids => [@editable_page.id, @noneditable_page.id]
    assert_response 403

    # revert_to
    # can't find route...
#    put :revert_to, :id => @editable_page.id
#    assert_response :redirect

#    put :revert_to, :id => @noneditable_page.id
#    assert_response :error # shouldn't it be 403?
  end

  def test_destroy_permissions
    login_as(@user)

    delete :destroy, :id => @editable_page
    assert_response :redirect

    delete :destroy, :id => @noneditable_page
    assert_response 403
    assert_template "cms/shared/access_denied"
  end
end


