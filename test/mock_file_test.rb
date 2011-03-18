require File.join(File.dirname(__FILE__), 'test_helper')

class MockFileTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end


  test "mock files can have data read from them" do
    file = mock_file()
    assert_equal "", file.path
    assert_equal "", open(file.path) { |f| f.read }
  end
end