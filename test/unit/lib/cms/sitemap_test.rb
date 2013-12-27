require "test_helper"

module Cms
  class MoveSections < ActiveSupport::TestCase

    def setup
      @root = create(:root_section)
      @parent = create(:section, :parent => @root, :name => "Parent")
      @a = create(:section, :parent => @parent, :name => "A")
      @a1 = create(:page, :section => @a, :name => "A1")
      @a2 = create(:page, :section => @a, :name => "A2")
      @a3 = create(:page, :section => @a, :name => "A3")
      @b = create(:section, :parent => @parent, :name => "B")
      @b1 = create(:page, :section => @b, :name => "B1")
      @b2 = create(:page, :section => @b, :name => "B2")
      @b3 = create(:page, :section => @b, :name => "B3")

      @node_a = @a.node
      @node_b = @b.node
      @node_a1 = @a1.section_node
      @node_a2 = @a2.section_node
      @node_a3 = @a3.section_node
      @node_b1 = @b1.section_node
      @node_b2 = @b2.section_node
      @node_b3 = @b3.section_node
      reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)

      # Use this to print out complete table data
      # log_table_without_stamps(SectionNode)
    end

    def test_reorder_nodes_within_same_section
      @node_a2.move_to(@a, 1)
      reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
      assert_properties(@node_a, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @a.id, :position => 1)
      assert_properties(@node_b, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @b.id, :position => 2)
      assert_properties(@node_a1, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a1.id, :position => 2)
      assert_properties(@node_a2, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a2.id, :position => 1)
      assert_properties(@node_a3, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a3.id, :position => 3)
      assert_properties(@node_b1, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b1.id, :position => 1)
      assert_properties(@node_b2, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b2.id, :position => 2)
      assert_properties(@node_b3, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b3.id, :position => 3)
    end

    def test_move_nodes_to_different_section
      @node_a2.move_to(@b, 2)
      reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
      assert_properties(@node_a, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @a.id, :position => 1)
      assert_properties(@node_b, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @b.id, :position => 2)
      assert_properties(@node_a1, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a1.id, :position => 1)
      assert_properties(@node_a2, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @a2.id, :position => 2)
      assert_properties(@node_a3, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a3.id, :position => 2)
      assert_properties(@node_b1, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b1.id, :position => 1)
      assert_properties(@node_b2, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b2.id, :position => 3)
      assert_properties(@node_b3, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b3.id, :position => 4)
    end

    def test_move_nodes_to_beginning_of_different_section
      @node_a2.move_to(@b, 1)
      reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
      assert_properties(@node_a, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @a.id, :position => 1)
      assert_properties(@node_b, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @b.id, :position => 2)
      assert_properties(@node_a1, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a1.id, :position => 1)
      assert_properties(@node_a2, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @a2.id, :position => 1)
      assert_properties(@node_a3, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a3.id, :position => 2)
      assert_properties(@node_b1, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b1.id, :position => 2)
      assert_properties(@node_b2, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b2.id, :position => 3)
      assert_properties(@node_b3, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b3.id, :position => 4)
    end

    def test_move_nodes_to_end_of_different_section
      @node_a2.move_to(@b, 99)
      reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
      assert_properties(@node_a, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @a.id, :position => 1)
      assert_properties(@node_b, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @b.id, :position => 2)
      assert_properties(@node_a1, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a1.id, :position => 1)
      assert_properties(@node_a2, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @a2.id, :position => 4)
      assert_properties(@node_a3, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a3.id, :position => 2)
      assert_properties(@node_b1, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b1.id, :position => 1)
      assert_properties(@node_b2, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b2.id, :position => 2)
      assert_properties(@node_b3, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b3.id, :position => 3)
    end

    def test_put_page_at_the_bottom_when_section_is_changed
      @a2.update_attributes(:section => @b)
      reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
      assert_properties(@node_a, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @a.id, :position => 1)
      assert_properties(@node_b, :ancestry => ancestry_for(@parent), :node_type => "Cms::Section", :node_id => @b.id, :position => 2)
      assert_properties(@node_a1, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a1.id, :position => 1)
      assert_properties(@node_a2, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @a2.id, :position => 4)
      assert_properties(@node_a3, :ancestry => ancestry_for(@a), :node_type => "Cms::Page", :node_id => @a3.id, :position => 2)
      assert_properties(@node_b1, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b1.id, :position => 1)
      assert_properties(@node_b2, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b2.id, :position => 2)
      assert_properties(@node_b3, :ancestry => ancestry_for(@b), :node_type => "Cms::Page", :node_id => @b3.id, :position => 3)
    end

    def test_find_ancestors
      assert @root.ancestors.empty?
      assert_equal [@root], @parent.ancestors
      assert_equal [@root, @parent], @a.ancestors
      assert_equal [@root, @parent, @a], @a1.ancestors
    end

    def ancestry_for(section_or_page)
      "#{section_or_page.ancestry}/#{section_or_page.node.id}"
    end
  end

  class SitemapNavTest < ActiveSupport::TestCase

    def setup
      given_a_site_exists
      @page = create(:public_page, :section => root_section)
      @link = create(:link, :section => root_section)
    end
  end
  class SitemapTest < ActiveSupport::TestCase

    def setup

    end

    def teardown
    end

    test "ancestry_path" do
      section = create(:public_section)
      assert_equal "#{section.parent.node.id}/#{section.node.id}", section.node.ancestry_path
    end
    test "Build root section from factory" do
      root = create(:root_section)
      assert_not_nil root
      assert root.root?
    end

    test "Build section with parent = root_section from factory" do
      section = create(:public_section)
      assert_not_nil section
      assert_equal false, section.root?
      assert_equal true, section.parent.root?
    end

    test "Section has parent based on ancestry" do
      s = Section.create!(:name => "A", :parent => root, :path => "/a")
      assert_equal "#{root.node.id}", s.ancestry
    end


    test "Assign Parent sections" do
      child_section = SectionNode.create!(:parent => root.node)
      assert_equal "#{root.node.id}", child_section.ancestry
      assert_equal root.node, child_section.parent
    end

    test "Each Section has a section node (even the root one)" do
      r = root
      assert_not_nil r.node
      assert_nil r.node.ancestry
    end

    test "child_nodes" do
      page = create(:page, :section => root)
      section = create(:public_section, :parent => root)

      assert_equal [page.section_node, section.node], root.child_nodes
    end

    test "pages" do
      page1 = create(:page, :section => root)
      page2 = create(:page, :section => root)
      section = create(:public_section, :parent => root)

      assert_equal [page1, page2], root.pages
    end

    test "child_sections" do
      page1 = create(:page, :section => root)
      page2 = create(:page, :section => root)
      section = create(:public_section, :parent => root)

      assert_equal [section], root.child_sections
    end

    test "Order of pages should be unique within each section" do
      page = create(:page, :section => root)
      assert_equal 1, page.section_node.position

      subsection = create(:section, :parent => root)
      page3 = create(:page, :section => subsection)
      log_table_without_stamps(SectionNode)
      assert_equal 1, page3.section_node.position
    end

    test "The root section node has no parent section" do
      assert_nil SectionNode.new.parent_section
    end

    private

    def root
      @root ||= create(:root_section)
    end
  end
end