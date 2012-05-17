require "test_helper"

class I18nTest < ActiveSupport::TestCase

   test "Better naming for file_block.attachments.data_file_path" do
    assert_equal "Path", Cms::FileBlock.human_attribute_name('attachments.data_file_path', :default => "A Value I don't want")
  end
end