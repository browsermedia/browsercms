require "test_helper"

module Cms
  class ContentTypeGroupTest < ActiveSupport::TestCase

    def setup
      @type1 = ContentType.create!(:name => "Cms::Block", :group_name => "A")
      @type2 = ContentType.create!(:name => "Cms::Block", :group_name => "B")
    end

    test ".menu_list returns all groups" do
      groups = ContentTypeGroup.menu_list

      assert_equal 2, groups.size
      assert_equal ["A", "B"], groups.map {|g| g.name }
    end

    test "#types returns all types ordered by position" do
      @type3 = ContentType.create!(:name => "Cms::Block", :group_name => "A")

      group = ContentTypeGroup.where(:name=>"A").first
      assert_equal [@type1, @type3], group.types
    end

  end
end