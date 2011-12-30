require "test_helper"

module Cms
  class ImageBlockTest < ActiveSupport::TestCase

    def setup

    end

    def teardown

    end

    test "default table_name" do
      assert_equal Namespacing.prefix("file_blocks"), ImageBlock.table_name
    end

    test "non_versioned_columns should not include the version_foreign_ken" do
      assert ImageBlock.non_versioned_columns.include?("original_record_id")
    end

    test "version_foreign_key" do
      assert_equal :original_record_id, ImageBlock.version_foreign_key
    end

    test "create works" do
      ImageBlock.create!(:name=>"test")
    end
  end
end