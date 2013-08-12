require 'minitest_helper'

class ActiveRecord::BaseTest < ActiveSupport::TestCase
  def test_updated_on_string
    base = Cms::HtmlBlock.new
    assert_nil base.updated_on_string
    base.updated_at = Time.zone.parse("1978-07-06")
    assert_equal "Jul 6, 1978", base.updated_on_string
  end
end

# Must use vanilla TestCase to avoid ActiveRecord setup conflicts
class TestExtensions < MiniTest::Unit

  #"If a connection throws an error when established, then we consider the database to not exist."
  def test_throws_error
    ActiveRecord::Base.expects(:connection).raises(StandardError)
    assert_equal false, ActiveRecord::Base.database_exists?
  end

  # "If we can establish a connection, the database exists"
  def test_exists
    assert_equal true, ActiveRecord::Base.database_exists?
  end
end
