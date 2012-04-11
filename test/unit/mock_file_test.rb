require 'test_helper'

class MockFileTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end


  test "mock files can have data read from them" do
    file = mock_file(:original_filename=>"version1.txt")
    assert_not_nil file.path
    assert_equal "v1", open(file.path) { |f| f.read }
  end
end