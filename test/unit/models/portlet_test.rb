require File.join(File.dirname(__FILE__), '/../../test_helper')

class PortletTest < ActiveSupport::TestCase

  def test_dynamic_attributes
    portlet = DynamicPortlet.create(:name => "Test", :foo => "FOO")
    assert_equal "FOO", Portlet.find(portlet.id).foo
    assert_equal "Dynamic Portlet", portlet.portlet_type_name
  end

  def test_portlets_consistently_load_the_same_number_of_types
    
    list = Portlet.types
    assert list.size > 0

    DynamicPortlet.create!(:name=>"test 1")
    DynamicPortlet.create!(:name=>"test 2")

    assert_equal list.size, Portlet.types.size
  end
end