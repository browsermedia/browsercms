require File.join(File.dirname(__FILE__), '/../../test_helper')

class HashTest < ActiveSupport::TestCase
  def test_except
    x = {:a => 1, :b => 2}
    assert_equal({:b => 2}, x.except(:a))
    assert_equal({:a => 1, :b => 2}, x)
  end

  # Test the behavior of out extract_only! method
  def test_extract_only!
    x = {:a => 1, :b => 2}
    y = x.extract_only!(:b, :c)
    assert_equal({:a => 1}, x)
    assert_equal({:b => 2}, y)
  end

  # This exists only to confirm the behavior of extract! (from ActiveSupport) is different then our extract_only!.
  # If this ever changes, we can remove extract_only!
  test "ActiveSupport Hash#extract! will add nil keys if they don't exist" do
    x = {:a => 1, :b => 2}
    y = x.extract!(:b, :c)
    assert_equal({:b => 2, :c=>nil}, y, "Even though :c didn't exist in the original hash, ActiveSupport 3.0.0 adds it as a side effect.")     
  end
  
end