require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::FileBlocksControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    login_as_cms_admin
  end
  
  def test_file_block_search
    @file = mock_file(:read => "This is a test")
    @file_block = Factory(:file_block, :attachment_section => root_section, 
      :attachment_file => @file, 
      :attachment_file_path => "/test.txt", 
      :name => "Test File", 
      :publish_on_save => true)
    @foo_section = Factory(:section, :name => "Foo", :parent => root_section)

    get :index, :section_id => root_section.id
    assert_response :success
    assert_select "td", "Test File"

    get :index, :section_id => @foo_section.id
    assert_response :success
    assert_select "td", {:count => 0, :text => "Test File"}

    get :index, :section_id => 'all'
    assert_response :success
    assert_select "td", "Test File"
  end

end