require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::SectionNodesControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
  end
  
  def test_index
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