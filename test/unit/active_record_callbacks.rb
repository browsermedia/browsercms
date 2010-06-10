require File.join(File.dirname(__FILE__), '/../test_helper')

class ActiveRecordCallbacksTest < ActiveSupport::TestCase

  test "When callbacks occur" do
    b = HtmlBlock.new(:name=>"NAME")
    assert b.save
  end
end