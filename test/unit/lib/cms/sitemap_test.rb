require "test_helper"

class SitemapTest < ActiveSupport::TestCase

  def setup

  end

  def teardown
  end

  test "Build root section from factory" do
    root = Factory(:root_section)
    assert_not_nil root
    assert root.root?
  end

  test "Build section with parent = root_section from factory" do
    section = Factory(:public_section)
    assert_not_nil section
    assert_equal false, section.root?
    assert_equal true, section.parent.root?
  end

  test "Section has parent based on ancestry" do
    s = Section.create!(:name=>"A", :parent=>root, :path=>"/a")
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
    page = Factory(:page, :section=>root)
    section = Factory :public_section, :parent=>root

    assert_equal [page.section_node, section.node], root.child_nodes
  end

  test "pages" do
    page1 = Factory(:page, :section=>root)
    page2 = Factory(:page, :section=>root)
    section = Factory :public_section, :parent=>root

    assert_equal [page1, page2], root.pages
  end

  test "child_sections" do
    page1 = Factory(:page, :section=>root)
    page2 = Factory(:page, :section=>root)
    section = Factory :public_section, :parent=>root

    assert_equal [section], root.child_sections
  end

  private

  def root
    @root ||= Factory(:root_section)
  end
end