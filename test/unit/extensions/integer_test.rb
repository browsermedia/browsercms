require File.join(File.dirname(__FILE__), '/../../test_helper')

class IntegerTest < ActiveSupport::TestCase
  def test_round_bytes
    assert_equal "99.44 MB", (99.megabytes + 450.kilobytes).round_bytes
    assert_equal "12.04 KB", (12.kilobytes + 45).round_bytes
    assert_equal "999 bytes", 999.round_bytes
    assert_equal "0 bytes", nil.round_bytes
  end
end