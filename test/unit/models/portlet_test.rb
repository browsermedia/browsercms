require File.join(File.dirname(__FILE__), '/../../test_helper')

class PortletTest < ActiveSupport::TestCase

  def test_dynamic_attributes
    portlet = DynamicPortlet.create(:name => "Test", :foo => "FOO")
    assert_equal "FOO", Portlet.find(portlet.id).foo
    assert_equal "Dynamic Portlet", portlet.portlet_type_name
  end
  
end