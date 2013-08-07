require 'test_helper'

class CategoryTypeTest < ActiveSupport::TestCase

  test "#create! with publish_on_save" do
    assert Cms::CategoryType.create! name: "Colors", publish_on_save: true
  end

  def test_create
    category_type = Cms::CategoryType.new(:name => "Test")
    assert category_type.save
  end
end
