require 'test_helper'

class CategoryTypeTest < ActiveSupport::TestCase
  def test_create
    category_type = Cms::CategoryType.new(:name => "Test")
    assert category_type.save
  end
end
