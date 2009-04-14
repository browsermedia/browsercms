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
  
  def test_update
    @section = Factory(:section, :name => "V1", :parent => root_section)
    
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
