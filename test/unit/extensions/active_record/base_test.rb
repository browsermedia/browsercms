require File.join(File.dirname(__FILE__), '/../../../test_helper')

class ActiveRecord::BaseTest < ActiveSupport::TestCase
  def test_updated_on_string
    base = HtmlBlock.new
    assert_nil base.updated_on_string
    base.updated_at = Time.zone.parse("1978-07-06")
    assert_equal "Jul 6, 1978", base.updated_on_string
  end
end