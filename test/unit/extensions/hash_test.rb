require 'test_helper'

class HashTest < ActiveSupport::TestCase
  def test_except
    x = {:a => 1, :b => 2}
    assert_equal({:b => 2}, x.except(:a))
    assert_equal({:a => 1, :b => 2}, x)
  end

  # Confirms ActiveSupport::Hash#extract! behavior works as we expect.
  def test_extract!
    x = {:a => 1, :b => 2}
    y = x.extract!(:b, :c)
    assert_equal({:b => 2}, y)
    assert_equal({:a => 1}, x)

  end


  
end