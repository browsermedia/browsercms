require "test_helper"

class I18nTest < ActiveSupport::TestCase

  def setup
    @original_block = create(:file_block, :attachment_file_path => "/another")

  end

  test "Don't add generic errors for invalid attachments'" do
    duplicate = build(:file_block, :attachment_file_path => "/another")

    should_have_duplicate_path_error(duplicate)
    generic_invalid_error_should_be_filtered(duplicate)
  end

  test "Don't add generic errors for invalid attachments on any attaching'" do
    duplicate = build(:image_block, :attachment_file_path => "/another")

    should_have_duplicate_path_error(duplicate)
    generic_invalid_error_should_be_filtered(duplicate)

  end

  test "Better naming for file_block.attachments.data_file_path" do
    assert_equal "Path", Cms::FileBlock.human_attribute_name('attachments.data_file_path', :default => "A Value I don't want")
  end

  private

  def generic_invalid_error_should_be_filtered(duplicate)
    refute(duplicate.errors.keys.include?(:"attachments"), "No generic error")
    assert_equal 1, duplicate.errors.size, "If this fails, it might because more validations were added to Cms::Attaching or FileBlock"
  end

  def should_have_duplicate_path_error(duplicate)
    refute duplicate.valid?
    assert(duplicate.errors.keys.include?(:"attachments.data_file_path"), "Should only have the duplicate path error")
  end
end