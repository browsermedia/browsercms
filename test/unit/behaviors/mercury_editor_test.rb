require "test_helper"

class MecuryEditorTest < ActiveSupport::TestCase

  test "#editor_type_for Text Areas" do
    field_info = Cms::HtmlBlock.new.editor_info(:content)
    assert_equal "full", field_info[:region]
    assert_equal "div", field_info[:element]
  end

  test "#editor_type_for text fields" do
    field_info = content_block().editor_info(:name)
    assert_equal "simple", field_info[:region]
    assert_equal "span", field_info[:element]
  end

  private

  # Factory for a simple content block.
  def content_block
    Cms::HtmlBlock.new
  end
end