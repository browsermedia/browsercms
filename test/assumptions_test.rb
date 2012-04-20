require "test_helper"

module Cms

  # To avoid hard to debug errors associated with testing,
  # we verify some assumptions here about the state of the database and other things.
  class AssumptionsTest < ActiveSupport::TestCase

    test "tests assume there is no data in the database before starting" do
      assert_equal 0, Section.count
      assert_equal 0, Page.count
      assert_equal 0, Permission.count
    end
  end
end