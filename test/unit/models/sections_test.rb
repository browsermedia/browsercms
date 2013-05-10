require 'test_helper'

module Cms
  class SectionTest < ActiveSupport::TestCase

    def setup
      @root = create(:root_section)
    end

    test "prepending_path" do
      assert_equal "/", Section.new(:path => "/").prependable_path
      assert_equal "/system/", Section.new(:path => "/system").prependable_path
    end

    def test_not_allow_slash_in_name
      section = build(:section, :name => "OMG / WTF / BBQ")
      assert !section.valid?
      assert_has_error_on section, :name, "cannot contain '/'"
    end

    test "sections return all child sections of a section" do
      s = create(:public_section)
      assert_equal [s], s.parent.sections
    end

    def test_create_sub_section
      sub = create(:section, :name => "Sub Section", :parent => root_section)
      assert_equal sub, root_section.sections.last
      assert_equal root_section, sub.parent
    end

    def test_move_into_another_section
      foo = create(:section, :name => "Foo", :parent => @root)
      bar = create(:section, :name => "Bar", :parent => @root)
      assert_equal @root, foo.parent
      assert foo.move_to(bar)
      assert_equal bar, foo.parent
    end

    def test_cannot_move_root_section
      foo = create(:section, :name => "Foo", :parent => @root)
      assert !@root.move_to(foo)
    end

    def test_find_first_page_or_link_in_section_page
      @a = create(:section, :parent => @root, :name => "A")
      @a1 = create(:section, :parent => @a, :name => "A1")
      @a1a = create(:section, :parent => @a1, :name => "A1a")
      @foo = create(:page, :section => @a1a, :name => "Foo")
      @b = create(:section, :parent => @root, :name => "B")

      assert_equal @foo, @a.first_page_or_link
      assert_equal @foo, @a1.first_page_or_link
      assert_equal @foo, @a1a.first_page_or_link
      assert_nil @b.first_page_or_link
    end

    def test_find_first_page_or_link_in_section_link
      @a = create(:section, :parent => @root, :name => "A")
      @a1 = create(:link, :section => @a, :name => "A1")
      @a2 = create(:page, :section => @a, :name => "A2")

      assert_equal @a1, @a.first_page_or_link

      @a2.section_node.move_to(@a, 0)

      assert_equal @a2, @a.first_page_or_link
    end

    def test_find_first_page_or_link_after_delete
      @a = create(:section, :parent => @root, :name => "A")
      @a1 = create(:page, :section => @a, :name => "A1")
      @a2 = create(:page, :section => @a, :name => "A2")
      @a3 = create(:page, :section => @a, :name => "A3")
      assert_equal @a1, @a.first_page_or_link
      @a1.destroy

      assert_equal @a2, @a.first_page_or_link
    end

    def test_find_by_name_path
      @a = create(:section, :parent => root_section, :name => "A")
      @b = create(:section, :parent => @a, :name => "B")
      @c = create(:section, :parent => @b, :name => "C")

      assert_equal root_section, Cms::Section.find_by_name_path("/")
      assert_equal @a, Cms::Section.find_by_name_path("/A/")
      assert_equal @b, Cms::Section.find_by_name_path("/A/B/")
      assert_equal @c, Cms::Section.find_by_name_path("/A/B/C/")
    end

    def test_section_with_sub_section
      @section = create(:section, :parent => root_section)
      create(:section, :parent => @section)

      assert !@section.empty?
      assert !@section.deletable?

      section_count = Cms::Section.count
      assert !@section.destroy
      assert_equal section_count, Cms::Section.count

    end

    test "sections with pages should not be empty?" do
      @section = create(:section, :parent => @root)
      create(:page, :section => @section)

      assert_equal false, @section.empty?
    end

    def test_section_with_page_should_not_be_deletable
      @section = create(:section, :parent => @root)
      create(:page, :section => @section)

      assert !@section.deletable?

      section_count = Cms::Section.count
      assert !@section.destroy
      assert_equal section_count, Cms::Section.count
    end

    def test_a_root_section_shouldnt_be_deletable_even_without_children

      assert !root_section.deletable?

      section_count = Cms::Section.count
      assert !root_section.destroy
      assert_equal section_count, Cms::Section.count
    end

    def test_empty_section
      @section = create(:section, :parent => @root)

      assert @section.empty?
      assert @section.deletable?

      section_count = Cms::Section.count
      section_node_count = Cms::SectionNode.count
      assert @section.destroy
      assert_decremented section_count, Cms::Section.count
      assert_decremented section_node_count, Cms::SectionNode.count
    end

    def test_creating_page_with_reserved_path
      @section = Cms::Section.new(:name => "FAIL", :path => "/cms")
      assert_not_valid @section
      assert_has_error_on(@section, :path, "is invalid, '/cms' a reserved path")

      @section = Cms::Section.new(:name => "FAIL", :path => "/cache")
      assert_not_valid @section
      assert_has_error_on(@section, :path, "is invalid, '/cache' a reserved path")

      @section = Cms::Section.new(:name => "FTW", :path => "/whatever")
      assert_valid @section
    end

    def test_old_syntax_for_marking_group_sections
      given_there_is_a_group = create(:group)

      groups = Cms::Group.all(&:id)
      assert_equal Cms::Group, groups[0].class, "This is previous"

      groups = Cms::Group.all()
      assert_equal Cms::Group, groups[0].class, "No difference between this and the previous call."

      group_ids = Cms::Group.all.map(&:id)
      assert_equal Fixnum, group_ids[0].class
    end

    def test_new_section_with_groups
      section = Cms::Section.new(:allow_groups => :all)
      assert_equal Cms::Group.all, section.groups

    end

    def test_new_section_with_no_groups
      s = Cms::Section.new(:allow_groups => :none)
      assert_equal 0, s.groups.size
    end

    def test_create_section
      s = Cms::Section.create!(:name => "For All", :path => "/", :allow_groups => :all)

      assert_equal Cms::Group.count, Cms::Section.with_path("/").first.groups.size
    end
  end

  class TestsWithoutFixtures < ActiveSupport::TestCase
    def setup
      remove_all_sitemap_fixtures_to_avoid_bugs
    end

    def test_find_by_name_path
      @a = create(:section, :parent => root_section, :name => "A")
      @b = create(:section, :parent => @a, :name => "B")
      @c = create(:section, :parent => @b, :name => "C")

      assert_equal root_section, Section.find_by_name_path("/")
      assert_equal @a, Section.find_by_name_path("/A/")
      assert_equal @b, Section.find_by_name_path("/A/B/")
      assert_equal @c, Section.find_by_name_path("/A/B/C/")
    end
  end

  class TestAncestors < ActiveSupport::TestCase

    def setup
      given_there_is_a_guest_group
      @visible_section = create(:public_section, :parent => root_section)
      @hidden_section = create(:public_section, :parent => root_section, :hidden => true)
      @visible_page = create(:public_page, :section => root_section)
      @hidden_page = create(:public_page, :hidden => true, :section => root_section)
      @file_block = create(:file_block, :parent => root_section)
    end

    test "visible_child_nodes should include non-hidden sections and non-hidden pages" do
      assert_equal [@visible_section.node, @visible_page.node], root_section.visible_child_nodes
    end

    test "ancestors :include_self" do
      assert_equal [root_section], @visible_section.ancestors
      assert_equal [root_section, @visible_section], @visible_section.ancestors(:include_self => true)
    end

    test "#ancestry_path delegates to SectionNode" do
      assert_equal @visible_section.node.ancestry_path, @visible_section.ancestry_path
    end

    test "#build_section creates a new section within this section" do
      new_section = @visible_section.build_section
      assert_equal @visible_section, new_section.parent
    end

    test "#partial_for" do
      assert_equal "section", @visible_section.partial_for
      assert_equal "page", @visible_page.partial_for
      assert_equal "link", create(:link, :section => root_section).partial_for
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
      link = create(:link, :section => root_section)
      sn = link.section_node
      assert_equal sn.object_id, sn.node.section_node.object_id
    end

    test "#public?" do
      assert @visible_section.public?
      refute create(:section).public?
    end

    test "#sitemap should return root_section as key" do
      assert_equal root_section.node, Section.sitemap.keys.first
    end

    test "#sitemap should include visible pages" do
      assert_equal [@visible_section, @hidden_section, @visible_page, @hidden_page], content_in_root_section
    end

    test "#sitemap should exclude files" do
      refute content_in_root_section.include?(@file_block)
    end

    test "#sitemap should include addressable content blocks" do
      product = Product.create!(name: "Hello", parent: root_section)
      assert child_nodes_in(root_section).include?(product), "Verify product is in root section"
      assert content_in_root_section.include?(product), "Verify it doesn't get filtered out when returned by sitemap'"
    end

    test "#master_section_list" do
      subsection = create(:public_section, :parent => @visible_section, :name => "Child 1")
      sections = root_section.master_section_list
      assert_equal [@visible_section, subsection, @hidden_section], sections
      assert_equal "#{@visible_section.name}", sections[0].full_path
      assert_equal "#{@visible_section.name} / #{subsection.name}", sections[1].full_path
      assert_equal "#{@hidden_section.name}", sections[2].full_path
    end


    private

    def child_nodes_in(section)
      section.child_nodes.map { |sn| sn.node }
    end

    # Pages/section/etc in / that is visible in the sitemap
    def content_in_root_section
      Section.sitemap.first[1].keys.map { |sn| sn.node }
    end
  end


end