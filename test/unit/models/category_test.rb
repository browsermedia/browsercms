require 'test_helper'

class CategoryTest < ActiveSupport::TestCase


  test "#create! with publish_on_save" do
    assert create(:category,  publish_on_save: true)
  end

  def test_creating_categories
    @a_type = create(:category_type, :name => "A")
    @b_type = create(:category_type, :name => "B")
    
    @a = create(:category, :name => "A", :category_type => @a_type)
    @a1 = create(:category, :name => "A1", :category_type => @a_type, :parent => @a)
    @a1a = create(:category, :name => "A1a", :category_type => @a_type, :parent => @a1)
    @a2 = create(:category, :name => "A2", :category_type => @a_type, :parent => @a)
    @b = create(:category, :name => "B", :category_type => @b_type)
    @b1 = create(:category, :name => "B1", :category_type => @b_type, :parent => @b)
    @b2 = create(:category, :name => "B2", :category_type => @b_type, :parent => @b)
    
    assert @a.parent.blank?
    assert_equal [@a1, @a2], @a.children
    
    assert_equal @a, @a1.parent
    assert_equal [@a1a], @a1.children
    
    assert_equal @a, @a2.parent
    assert @a2.children.blank?
    
    assert @a.ancestors.blank?
    assert_equal [@a], @a1.ancestors
    assert_equal [@a, @a1], @a1a.ancestors
    
    assert_equal "#{@a.name}", @a.path
    assert_equal "#{@a.name} > #{@a1.name}", @a1.path
    assert_equal "#{@a.name} > #{@a1.name} > #{@a1a.name}", @a1a.path
    
    assert_equal [
      "#{@a.name}",
      "#{@a.name} > #{@a1.name}",
      "#{@a.name} > #{@a1.name} > #{@a1a.name}",
      "#{@a.name} > #{@a2.name}"
    ], Cms::Category.of_type("A").all.map(&:path)
  end
end
