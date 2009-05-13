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
