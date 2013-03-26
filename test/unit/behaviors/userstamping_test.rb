require "test_helper"

class UserStampingTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  test "if no current user, then timestamp should be nil" do
    Cms::User.expects(:current).returns(nil).at_least_once
    block = Cms::HtmlBlock.create!(:name=>"A")

    assert_nil block.created_by
    assert_nil block.updated_by
  end

  test "if no current user is false, then timestamp should be nil" do
    Cms::User.expects(:current).returns(false).at_least_once
    block = Cms::HtmlBlock.create!(:name=>"A")
    assert_nil block.created_by
    assert_nil block.updated_by
  end
end