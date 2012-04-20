require "test_helper"

# Verify how ActiveModel works
class ActiveModelNamingTest < ActiveSupport::TestCase
  test "#model_name" do
    assert_equal "VersionedAttachable", VersionedAttachable.model_name
  end
end

class NamingTest < ActiveSupport::TestCase

  test "#content_block_type" do
    assert_equal "versioned_attachable", content_block.content_block_type
  end

  test "#path_name" do
    assert_equal "versioned_attachables", content_block.class.path_name
  end
  private

  def content_block
    @content_block ||= VersionedAttachable.new
  end
end