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
  
  def test_index_as_contributor_with_subsections
    # DRYME copypaste from UserPermissionTest
    @user = Factory(:user)
    login_as(@user)
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @group.permissions << create_or_find_permission_named("edit_content")
    @group.permissions << create_or_find_permission_named("publish_content")
    @user.groups << @group
    @editable_section = Factory(:section, :parent => root_section, :name => "Editable")
    @editable_subsection = Factory(:section, :parent => @editable_section, :name => "Editable Subsection")
    @group.sections << @editable_section
    @noneditable_section = Factory(:section, :parent => root_section, :name => "Not Editable")
    @editable_page = Factory(:page, :section => @editable_section, :name => "Editable Page")
    @editable_subpage = Factory(:page, :section => @editable_subsection, :name => "Editable SubPage")
    @noneditable_page = Factory(:page, :section => @noneditable_section, :name => "Non-Editable Page")
    @editable_link = Factory(:link, :section => @editable_section, :name => "Editable Link")
    @editable_sublink = Factory(:link, :section => @editable_subsection, :name => "Editable SubLink")
    @noneditable_link = Factory(:link, :section => @noneditable_section, :name => "Non-Editable Link")
    noneditables = [@noneditable_section, @noneditable_page, @noneditable_link]
    editables = [@editable_section, @editable_subsection, 
      @editable_page, @editable_subpage, 
      @editable_link, @editable_sublink]

    get :index
    assert_response :success
    # Brittle: 9 is noneditables.size + %w(MySite system Home NotFound AccessDenied ServerError).size
    assert_select "td.node.non-editable", 9
    # TODO fix this test
    # no editable, but all noneditables should be ".non-editable"
    # assert_select "td.node.non-editable" do |td_nes|
      # assert noneditables.all? do |ne|
        # td_nes.any? do |td|
          # assert_select "div", ne.name
        # end
      # end
      # assert editables.none? do |editable|
        # td_nes.any? do |td|
          # assert_select "div", editable.name
        # end
      # end
    # end
  end
  
end