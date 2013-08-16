require 'test_helper'

class CategoryTypeTest < ActiveSupport::TestCase

  test "#create! with publish_on_save" do
    assert Cms::CategoryType.create! name: "Colors", publish_on_save: true
  end

  def test_create
    category_type = Cms::CategoryType.new(:name => "Test")
    assert category_type.save
  end

  test ".named" do
    colors = Cms::CategoryType.create!(:name => "Colors")
    flowers = Cms::CategoryType.create!(:name => "Flowers")
    assert_equal [colors], Cms::CategoryType.named("Colors").to_a
  end
end
