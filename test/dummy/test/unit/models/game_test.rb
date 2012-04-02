require File.join(File.dirname(__FILE__), '/../../test_helper')

class GameTest < ActiveSupport::TestCase

  test "should be able to create new block" do
    assert Game.create!
  end
  
end