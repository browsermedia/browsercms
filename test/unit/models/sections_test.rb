require File.join(File.dirname(__FILE__), '/../../test_helper')

class SectionTest < ActiveSupport::TestCase
  
  def test_not_allow_slash_in_name
    section = Factory.build(:section, :name => "OMG / WTF / BBQ")
    assert !section.valid?
    assert_has_error_on section, :name, "cannot contain '/'"
  end
  
  def test_create_sub_section
    sub = Factory(:section, :name => "Sub Section", :parent => root_section)
    assert_equal sub, root_section.sections.first(:order => "created_at desc")
    assert_equal root_section, sub.parent
  end
  
  def test_move_into_another_section
    foo = Factory(:section, :name => "Foo", :parent => root_section)
    bar = Factory(:section, :name => "Bar", :parent => root_section)
    assert_equal root_section, foo.parent
    assert foo.move_to(bar)
    assert_equal bar, foo.parent
  end
  
  def test_cannot_move_root_section
    foo = Factory(:section, :name => "Foo", :parent => root_section)
    assert !root_section.move_to(foo)
  end
  
  def test_find_first_page_in_section
    @a = Factory(:section, :parent => root_section, :name => "A")
    @a1 = Factory(:section, :parent => @a, :name => "A1")
    @a1a = Factory(:section, :parent => @a1, :name => "A1a")
    @foo = Factory(:page, :section => @a1a, :name => "Foo")
    @b = Factory(:section, :parent => root_section, :name => "B")
    
    assert_equal @foo, @a.first_page
    assert_equal @foo, @a1.first_page
    assert_equal @foo, @a1a.first_page
    assert_nil @b.first_page
  end
  
  def test_find_by_name_path
    @a = Factory(:section, :parent => root_section, :name => "A")
    @b = Factory(:section, :parent => @a, :name => "B")
    @c = Factory(:section, :parent => @b, :name => "C")
    
    assert_equal root_section, Section.find_by_name_path("/")
    assert_equal @a, Section.find_by_name_path("/A/")
    assert_equal @b, Section.find_by_name_path("/A/B/")
    assert_equal @c, Section.find_by_name_path("/A/B/C/")
  end  
  
  def test_section_with_sub_section
    @section = Factory(:section, :parent => root_section)
    Factory(:section, :parent => @section)

    assert !@section.empty?
    assert !@section.deletable?

    section_count = Section.count
    assert !@section.destroy
    assert_equal section_count, Section.count
  end
  
  def test_section_with_page
    @section = Factory(:section, :parent => root_section)
    Factory(:page, :section => @section)

    assert !@section.empty?
    assert !@section.deletable?
    
    section_count = Section.count
    assert !@section.destroy
    assert_equal section_count, Section.count
  end
  
  def test_root_section
    @section = root_section

    assert !@section.empty?
    assert !@section.deletable?
    
    section_count = Section.count
    assert !@section.destroy
    assert_equal section_count, Section.count
  end  
  
  def test_empty_section
    @section = Factory(:section, :parent => root_section)
    
    assert @section.empty?
    assert @section.deletable?
    
    section_count = Section.count
    assert @section.destroy
    assert_decremented section_count, Section.count
  end  
  
end