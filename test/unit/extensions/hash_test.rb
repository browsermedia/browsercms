require File.join(File.dirname(__FILE__), '/../../test_helper')

class HashTest < ActiveSupport::TestCase
  def test_except
    x = {:a => 1, :b => 2}
    assert_equal({:b => 2}, x.except(:a))
    assert_equal({:a => 1, :b => 2}, x)
  end
end