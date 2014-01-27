require File.join(File.dirname(__FILE__), '/../../test_helper')

class ListTest < ActiveSupport::TestCase

  test "Should be able to create new instance of a portlet" do
    assert ListPortlet.create!(:name => "New Portlet")
  end
  
end