require File.join(File.dirname(__FILE__), '/../../test_helper')

class SectionTest < ActiveSupport::TestCase
  
  def setup
    @root = Factory(:root_section)
  end
  
  def test_not_allow_slash_in_name
    section = Factory.build(:section, :name => "OMG / WTF / BBQ")
    assert !section.valid?
    assert_has_error_on section, :name, "cannot contain '/'"
  end

  test "sections return all child sections of a section" do
    s = Factory(:public_section)
    assert_equal [s], s.parent.sections
  end

  def test_create_sub_section
    sub = Factory(:section, :name => "Sub Section", :parent => @root)
    assert_equal sub, @root.sections.last
    assert_equal @root, sub.parent
  end
  
  def test_move_into_another_section
    foo = Factory(:section, :name => "Foo", :parent => @root)
    bar = Factory(:section, :name => "Bar", :parent => @root)
    assert_equal @root, foo.parent
    assert foo.move_to(bar)
    assert_equal bar, foo.parent
  end
  
  def test_cannot_move_root_section
    foo = Factory(:section, :name => "Foo", :parent => @root)
    assert !@root.move_to(foo)
  end
  
  def test_find_first_page_or_link_in_section_page
    @a = Factory(:section, :parent => @root, :name => "A")
    @a1 = Factory(:section, :parent => @a, :name => "A1")
    @a1a = Factory(:section, :parent => @a1, :name => "A1a")
    @foo = Factory(:page, :section => @a1a, :name => "Foo")
    @b = Factory(:section, :parent => @root, :name => "B")
    
    assert_equal @foo, @a.first_page_or_link
    assert_equal @foo, @a1.first_page_or_link
    assert_equal @foo, @a1a.first_page_or_link
    assert_nil @b.first_page_or_link
  end
  
  def test_find_first_page_or_link_in_section_link
    @a = Factory(:section, :parent => @root, :name => "A")
    @a1 = Factory(:link, :section => @a, :name => "A1")
    @a2 = Factory(:page, :section => @a, :name => "A2")

    assert_equal @a1, @a.first_page_or_link

    @a2.section_node.move_to(@a, 0)
    
    assert_equal @a2, @a.first_page_or_link
  end

  def test_find_first_page_or_link_after_delete
    @a = Factory(:section, :parent => @root, :name => "A")
    @a1 = Factory(:page, :section => @a, :name => "A1")
    @a2 = Factory(:page, :section => @a, :name => "A2")
    @a3 = Factory(:page, :section => @a, :name => "A3")
    assert_equal @a1, @a.first_page_or_link
    @a1.destroy
    
    assert_equal @a2, @a.first_page_or_link
  end

  def test_section_with_child_sections_should_not_be_deletable
    @section = Factory(:section, :parent => @root)
    Factory(:section, :parent => @section)

    assert !@section.empty?
    assert !@section.deletable?

    assert_no_difference 'Section.count; SectionNode.count' do
      @section.destroy
    end
  end

  test "sections with pages should not be empty?" do
    @section = Factory(:section, :parent => @root)
    Factory(:page, :section => @section)

    assert_equal false, @section.empty?
  end

  def test_section_with_page_should_not_be_deletable
    @section = Factory(:section, :parent => @root)
    Factory(:page, :section => @section)

    assert !@section.deletable?
    
    section_count = Section.count
    assert !@section.destroy
    assert_equal section_count, Section.count
  end
  
  def test_a_root_section_shouldnt_be_deletable_even_without_children
    root = Factory(:root_section)

    assert root.empty?
    assert !root.deletable?

    assert_no_difference 'Section.count' do
      assert !root.destroy
    end
  end  
  
  def test_empty_section
    @section = Factory(:section, :parent => @root)
    
    assert @section.empty?
    assert @section.deletable?

    section_count = Section.count
    section_node_count = SectionNode.count
    assert @section.destroy
    assert_decremented section_count, Section.count
    assert_decremented section_node_count, SectionNode.count
  end
  
  def test_creating_page_with_reserved_path
    @section = Section.new(:name => "FAIL", :path => "/cms")
    assert_not_valid @section
    assert_has_error_on(@section, :path, "is invalid, '/cms' a reserved path")
    
    @section = Section.new(:name => "FAIL", :path => "/cache")
    assert_not_valid @section
    assert_has_error_on(@section, :path, "is invalid, '/cache' a reserved path")
    
    @section = Section.new(:name => "FTW", :path => "/whatever")
    assert_valid @section
  end  

  def test_old_syntax_for_marking_group_sections
    groups = Group.all(&:id)
    assert_equal Group, groups[0].class, "This is previous"

    groups = Group.all()
    assert_equal Group, groups[0].class, "No difference between this and the previous call."

    group_ids = Group.all.map(&:id)
    assert_equal Fixnum, group_ids[0].class
  end

  def test_new_section_with_groups
    section = Section.new(:allow_groups=>:all)
    assert_equal Group.all, section.groups

  end

  def test_new_section_with_no_groups
    s = Section.new(:allow_groups=>:none)
    assert_equal 0, s.groups.size
  end

  def test_create_section
    s = Section.create!(:name=>"For All", :path=>"/", :allow_groups=>:all)

    assert_equal Group.count, Section.with_path("/").first.groups.size
  end
end

class TestsWithoutFixtures < ActiveSupport::TestCase
  def setup
    remove_all_sitemap_fixtures_to_avoid_bugs
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
end

class TestAncestors < ActiveSupport::TestCase

  def setup
    remove_all_sitemap_fixtures_to_avoid_bugs
    @visible_section = Factory(:public_section, :parent=>root_section)
    @hidden_section = Factory(:public_section, :parent=>root_section, :hidden=>true)
    @visible_page = Factory(:public_page, :section=>root_section)
    @hidden_page = Factory(:public_page, :hidden => true, :section=>root_section)
    @file_block = Factory(:file_block, :attachment_section => root_section, :attachment_file =>mock_file)
  end

  test "visible_child_nodes should include non-hidden sections and non-hidden pages" do
    assert_equal [@visible_section.node, @visible_page.node], root_section.visible_child_nodes
  end

  test "ancestors :include_self" do
    assert_equal [root_section], @visible_section.ancestors
    assert_equal [root_section, @visible_section], @visible_section.ancestors(:include_self=>true)
  end

  test "all_children_with_name" do
    assert_equal [@visible_section, @hidden_section], root_section.all_children_with_name
  end

  test "#ancestry_path delegates to SectionNode" do
    assert_equal @visible_section.node.ancestry_path, @visible_section.ancestry_path
  end

  test "#build_section creates a new section within this section" do
    new_section = @visible_section.build_section
    assert_equal @visible_section, new_section.parent
  end

  test "#navigation_children" do
    root = root_section
    assert_equal [@visible_section, @hidden_section, @visible_page, @hidden_page], root.navigation_children
    assert_equal root, @visible_section.parent
    assert_equal root, @visible_page.parent
  end

  test "#partial_for" do
    assert_equal "section", @visible_section.partial_for
    assert_equal "page", @visible_page.partial_for
    assert_equal "link", Factory(:link, :section=>root_section).partial_for
  end

  test "#status is cached" do
    assert_equal :unlocked, @visible_section.status
    assert_equal :unlocked, @visible_section.instance_variable_get(:@status)
  end

  test "Section#section_node should be the same object " do
    sn = root_section.section_node
    assert_equal sn.object_id, sn.node.section_node.object_id, "Should be the same object"
  end

  test "Page#section_node should be the same object" do
    sn = @visible_page.section_node
    assert_equal sn.object_id, sn.node.section_node.object_id
  end

  test "Link#section_node should be the same object" do
    link = Factory(:link, :section=>root_section)
    sn = link.section_node
    assert_equal sn.object_id, sn.node.section_node.object_id
  end

  test "#public?" do
    assert @visible_section.public?
    refute Factory(:section).public?
  end

  test "#sitemap" do
    sitemap = Section.sitemap
    assert_equal root_section.node, sitemap.keys.first
    assert_equal [@visible_section, @hidden_section, @visible_page , @hidden_page].map {|n|n.section_node}, sitemap[root_section.node].keys
  end
end
