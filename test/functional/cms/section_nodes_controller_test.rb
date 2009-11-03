require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::SectionNodesControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def test_index_as_admin
    login_as_cms_admin
    @foo = Factory(:section, :name => "Foo", :parent => root_section)
    @bar = Factory(:section, :name => "Bar", :parent => @foo)
    @page = Factory(:page, :name => "Test Page", :section => @bar)
    get :index
    assert_response :success
    assert_select "title", "Sitemap"
    assert_select "h1", "Sitemap"
    assert_select "#sitemap" do
      assert_select "ul#root_1" do
        assert_select "#section_#{root_section.id}" do
          assert_select "div", "My Site"
        end
      end
      assert_select "ul#section_node_#{@foo.node.id}" do
        assert_select "#section_#{@foo.id}" do
          assert_select "div", "Foo"
        end
      end
      assert_select "ul#section_node_#{@bar.node.id}" do
        assert_select "#section_#{@bar.id}" do
          assert_select "div", "Bar"
        end
        assert_select "#section_node_#{@page.section_node.id}" do
          assert_select "#page_#{@page.id}" do
            assert_select "div", "Test Page"
          end
        end
      end      
    end
  end
  
end

class Cms::SectionNodesControllerPermissionsTest < ActionController::TestCase
  tests Cms::SectionNodesController
  include Cms::ControllerTestHelper
  
  def setup
    # DRYME copypaste from UserPermissionTest
    @user = Factory(:user)
    login_as(@user)
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @group.permissions << create_or_find_permission_named("edit_content")
    @group.permissions << create_or_find_permission_named("publish_content")
    @user.groups << @group
    
    @editable_section = Factory(:section, :parent => root_section, :name => "Editable")
    @group.sections << @editable_section
    @editable_page = Factory(:page, :section => @editable_section, :name => "Editable Page")
    @editable_link = Factory(:link, :section => @editable_section, :name => "Editable Link")
    
    @noneditable_section = Factory(:section, :parent => root_section, :name => "Not Editable")
    @noneditable_page = Factory(:page, :section => @noneditable_section, :name => "Non-Editable Page")
    @noneditable_link = Factory(:link, :section => @noneditable_section, :name => "Non-Editable Link")
    
    @noneditables = [@noneditable_section, @noneditable_page, @noneditable_link]
    @editables = [@editable_section,
      @editable_page, 
      @editable_link,]
  end
  
  def test_index_as_contributor_with_subsections
    get :index
    assert_response :success
    
    # Check that each non-editable has the non-editable class, and that each editable does not have
    # the non-editable class
    @noneditables.each do |ne|
      assert_select "td.node.non-editable div", ne.name
    end
    @editables.each do |e|
      td = css_select("td##{e.class.to_s.underscore}_#{e.id}", e.name).first
      assert !td.attributes["class"].include?("non-editable")
    end
  end
end

