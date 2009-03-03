require File.join(File.dirname(__FILE__), '/../../test_helper')

class CategoryTest < ActiveSupport::TestCase
  def test_creating_categories
    @a_type = Factory(:category_type, :name => "A")
    @b_type = Factory(:category_type, :name => "B")
    
    @a = Factory(:category, :name => "A", :category_type => @a_type)
    @a1 = Factory(:category, :name => "A1", :category_type => @a_type, :parent => @a)
    @a1a = Factory(:category, :name => "A1a", :category_type => @a_type, :parent => @a1)
    @a2 = Factory(:category, :name => "A2", :category_type => @a_type, :parent => @a)
    @b = Factory(:category, :name => "B", :category_type => @b_type)
    @b1 = Factory(:category, :name => "B1", :category_type => @b_type, :parent => @b)
    @b2 = Factory(:category, :name => "B2", :category_type => @b_type, :parent => @b)
    
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
    ], Category.of_type("A").all.map(&:path)
  end
end