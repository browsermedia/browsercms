require File.join(File.dirname(__FILE__), '/../../test_helper')

class FindCategoryTest < ActiveSupport::TestCase

  test "Should be able to create new instance of a portlet" do
    assert FindCategoryPortlet.create!(:name => "New Portlet")
  end
  
end