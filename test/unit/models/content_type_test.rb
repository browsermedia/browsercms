require File.join(File.dirname(__FILE__), '/../../test_helper')

# Sample Model for testing naming/model classes
class Kindness < ActiveRecord::Base
  acts_as_content_block
end

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

  test "find_by_key handles names that end with s correctly" do
    ContentType.create!(:name => "Kindness", :group_name => "Anything")

    ct = ContentType.find_by_key("kindness")
    assert_not_nil ct
    assert_equal "Kindness", ct.display_name
  end

  test "calculate the model_class name with s" do
    ct = ContentType.new(:name=>"Kindness")
    assert_equal Kindness, ct.model_class
  end


end

