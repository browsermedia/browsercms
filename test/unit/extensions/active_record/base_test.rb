require 'test_helper'

class ActiveRecord::BaseTest < ActiveSupport::TestCase
  def test_updated_on_string
    base = HtmlBlock.new
    assert_nil base.updated_on_string
    base.updated_at = Time.zone.parse("1978-07-06")
    assert_equal "Jul 6, 1978", base.updated_on_string
  end
end

# Must use vanilla TestCase to avoid ActiveRecord setup conflicts
class TestExtensions < Test::Unit::TestCase

  def test_throws_error
  #test "If a connection throws an error when established, then we consider the database to not exist." do
    ActiveRecord::Base.expects(:connection).raises(StandardError)
    assert_equal false, ActiveRecord::Base.database_exists?
  end

  def test_exists
  #test "If we can establish a connection, the database exists"  do
    assert_equal true, ActiveRecord::Base.database_exists?
  end
end