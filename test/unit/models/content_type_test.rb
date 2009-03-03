require File.join(File.dirname(__FILE__), '/../../test_helper')

class ContentTypeTest < ActiveSupport::TestCase
  def setup
    @c = ContentType.new(:name => "HtmlBlock")
  end

  def test_model_class
    assert_equal HtmlBlock, @c.model_class
  end

  def test_display_name
    assert_equal "Text", @c.display_name
  end

  def test_display_name_plural
    assert_equal "Text", @c.display_name_plural
  end

  def test_content_block_type
    assert_equal "html_blocks", @c.content_block_type
  end
end