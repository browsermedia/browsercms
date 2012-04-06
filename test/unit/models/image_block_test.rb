require "test_helper"

module Cms
  class ImageBlockTest < ActiveSupport::TestCase

    def setup

    end

    def teardown

    end

    test "#parent" do
      image = create(:image_block)
      assert_equal root_section, image.parent
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

  end

  class PaperclipAttachmentsTest < ActiveSupport::TestCase
    def setup
      @image = build(:image_block)
      @image.save!
    end

    test "#attachable_type" do
      assert_equal "Cms::AbstractFileBlock", @image.attachable_type
    end

    test "#file is set" do
      assert_not_nil @image.file
    end

    test "#image is alias for #file" do
      assert_equal @image.file, @image.image
    end

    test ":image_block Factory defines a default attachment" do
      image = create(:image_block)
      assert_not_nil image.file
      assert_equal Cms::Attachment, image.file.class
    end
  end


end