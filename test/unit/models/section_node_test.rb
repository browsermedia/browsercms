require File.join(File.dirname(__FILE__), '/../../test_helper')

class SectionNodeTest < ActiveSupport::TestCase
  def setup
    @parent = Factory(:section, :parent => root_section, :name => "Parent")
    @a = Factory(:section, :parent => @parent, :name => "A")
    @a1 = Factory(:page, :section => @a, :name => "A1")
    @a2 = Factory(:page, :section => @a, :name => "A2")
    @a3 = Factory(:page, :section => @a, :name => "A3")
    @b = Factory(:section, :parent => @parent, :name => "B")
    @b1 = Factory(:page, :section => @b, :name => "B1")
    @b2 = Factory(:page, :section => @b, :name => "B2")
    @b3 = Factory(:page, :section => @b, :name => "B3")    
    
    @node_a = @a.node
    @node_b = @b.node
    @node_a1 = @a1.section_node
    @node_a2 = @a2.section_node
    @node_a3 = @a3.section_node
    @node_b1 = @b1.section_node
    @node_b2 = @b2.section_node
    @node_b3 = @b3.section_node
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)    
  end
  def test_reorder_nodes_within_same_section
    @node_a2.move_to(@a, 1)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    log_table_without_stamps(SectionNode)
    assert_properties(@node_a, :section_id => @parent.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    assert_properties(@node_b, :section_id => @parent.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    assert_properties(@node_a1, :section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 2)
    assert_properties(@node_a2, :section_id => @a.id, :node_type => "Page", :node_id => @a2.id, :position => 1)
    assert_properties(@node_a3, :section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 3)
    assert_properties(@node_b1, :section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 1)
    assert_properties(@node_b2, :section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 2)
    assert_properties(@node_b3, :section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 3)    
  end
  def test_move_nodes_to_different_section
    @node_a2.move_to(@b, 2)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    assert_properties(@node_a, :section_id => @parent.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    assert_properties(@node_b, :section_id => @parent.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    assert_properties(@node_a1, :section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 1)
    assert_properties(@node_a2, :section_id => @b.id, :node_type => "Page", :node_id => @a2.id, :position => 2)
    assert_properties(@node_a3, :section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 2)
    assert_properties(@node_b1, :section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 1)
    assert_properties(@node_b2, :section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 3)
    assert_properties(@node_b3, :section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 4)
  end
  def test_move_nodes_to_beginning_of_different_section
    @node_a2.move_to(@b, 1)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    assert_properties(@node_a, :section_id => @parent.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    assert_properties(@node_b, :section_id => @parent.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    assert_properties(@node_a1, :section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 1)
    assert_properties(@node_a2, :section_id => @b.id, :node_type => "Page", :node_id => @a2.id, :position => 1)
    assert_properties(@node_a3, :section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 2)
    assert_properties(@node_b1, :section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 2)
    assert_properties(@node_b2, :section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 3)
    assert_properties(@node_b3, :section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 4)
  end
  def test_move_nodes_to_end_of_different_section
    @node_a2.move_to(@b, 99)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    assert_properties(@node_a, :section_id => @parent.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    assert_properties(@node_b, :section_id => @parent.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    assert_properties(@node_a1, :section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 1)
    assert_properties(@node_a2, :section_id => @b.id, :node_type => "Page", :node_id => @a2.id, :position => 4)
    assert_properties(@node_a3, :section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 2)
    assert_properties(@node_b1, :section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 1)
    assert_properties(@node_b2, :section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 2)
    assert_properties(@node_b3, :section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 3)
  end
  def test_put_page_at_the_bottom_when_section_is_changed
    @a2.update_attributes(:section_id => @b.id)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    assert_properties(@node_a, :section_id => @parent.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    assert_properties(@node_b, :section_id => @parent.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    assert_properties(@node_a1, :section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 1)
    assert_properties(@node_a2, :section_id => @b.id, :node_type => "Page", :node_id => @a2.id, :position => 4)
    assert_properties(@node_a3, :section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 2)
    assert_properties(@node_b1, :section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 1)
    assert_properties(@node_b2, :section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 2)
    assert_properties(@node_b3, :section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 3)
  end
  def test_find_ancestors
    assert root_section.ancestors.empty?
    assert_equal [root_section], @parent.ancestors
    assert_equal [root_section, @parent], @a.ancestors
    assert_equal [root_section, @parent, @a], @a1.ancestors
  end
end