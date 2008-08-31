require File.dirname(__FILE__) + '/abstract_unit'
require File.dirname(__FILE__) + '/fixtures/mixin'
require 'pp'

class MixinNestedSetTest < Test::Unit::TestCase
  fixtures :mixins
  
  def setup
    # force so other tests besides test_destroy_dependent aren't affected
    NestedSetWithStringScope.acts_as_nested_set_options[:dependent] = :delete_all
  end
  
  ##########################################
  # HIGH LEVEL TESTS
  ##########################################
  def test_mixing_in_methods
    ns = NestedSet.new
    assert(ns.respond_to?(:all_children)) # test a random method
    
    check_method_mixins(ns)
    check_deprecated_method_mixins(ns) 
    check_class_method_mixins(NestedSet)
  end
  
  def check_method_mixins(obj)
    [:<=>, :all_children, :all_children_count, :ancestors, :before_create, :before_destroy, :check_full_tree, 
    :check_subtree, :children, :children_count, :full_set, :leaves, :leaves_count, :left_col_name, :level, :move_to_child_of, 
    :move_to_left_of, :move_to_right_of, :parent, :parent_col_name, :renumber_full_tree, :right_col_name, 
    :root, :roots, :self_and_ancestors, :self_and_siblings, :siblings].each { |symbol| assert(obj.respond_to?(symbol)) }
  end
  
  def check_deprecated_method_mixins(obj)
    [:add_child, :direct_children, :parent_column, :root?, :child?, :unknown?].each { |symbol| assert(obj.respond_to?(symbol)) }
  end
  
  def check_class_method_mixins(klass)
    [:root, :roots, :check_all, :renumber_all].each { |symbol| assert(klass.respond_to?(symbol)) }
  end
  
  def test_string_scope
    ns = NestedSet.new
    assert_equal("mixins.root_id IS NULL", ns.scope_condition)
    
    ns = NestedSetWithStringScope.new
    ns.root_id = 1
    assert_equal("mixins.root_id = 1", ns.scope_condition)
    ns.root_id = 42
    assert_equal("mixins.root_id = 42", ns.scope_condition)
    check_method_mixins ns
  end
  
  def test_without_scope_condition
    ns = NestedSet.new
    assert_equal("mixins.root_id IS NULL", ns.scope_condition)
    NestedSet.without_scope_condition do
      assert_equal("(1 = 1)", ns.scope_condition)
    end
    assert_equal("mixins.root_id IS NULL", ns.scope_condition)
  end
  
  def test_symbol_scope
    ns = NestedSetWithSymbolScope.new
    ns.root_id = 1
    assert_equal("mixins.root_id = 1", ns.scope_condition)
    ns.root_id = 42
    assert_equal("mixins.root_id = 42", ns.scope_condition)
    check_method_mixins ns
  end
  
  def test_protected_attributes
    ns = NestedSet.new(:parent_id => 2, :lft => 3, :rgt => 2)
    [:parent_id, :lft, :rgt].each {|symbol| assert_equal(nil, ns.send(symbol))}
  end
    
  def test_really_protected_attributes
    ns = NestedSet.new
    assert_raise(ActiveRecord::ActiveRecordError) {ns.parent_id = 1}
    assert_raise(ActiveRecord::ActiveRecordError) {ns.lft = 1}
    assert_raise(ActiveRecord::ActiveRecordError) {ns.rgt = 1}
  end
  
  ##########################################
  # CLASS METHOD TESTS
  ##########################################
  def test_class_root
    NestedSetWithStringScope.roots.each {|r| r.destroy unless r.id == 4001}
    assert_equal([NestedSetWithStringScope.find(4001)], NestedSetWithStringScope.roots)
    NestedSetWithStringScope.find(4001).destroy
    assert_equal(nil, NestedSetWithStringScope.root)
    ns = NestedSetWithStringScope.create(:root_id => 2)
    assert_equal(ns, NestedSetWithStringScope.root)
  end
  
  def test_class_root_again
    NestedSetWithStringScope.roots.each {|r| r.destroy unless r.id == 101}
    assert_equal(NestedSetWithStringScope.find(101), NestedSetWithStringScope.root)
  end
  
  def test_class_roots
    assert_equal(2, NestedSetWithStringScope.roots.size)
    assert_equal(10, NestedSet.roots.size) # May change if STI behavior changes
  end
  
  def test_check_all_1
    assert_nothing_raised {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.update_all("lft = 3", "id = 103")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
  end
  
  def test_check_all_2
    NestedSetWithStringScope.update_all("lft = lft + 1", "lft > 11 AND root_id = 101")
    NestedSetWithStringScope.update_all("rgt = rgt + 1", "lft > 11 AND root_id = 101")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all} 
  end
  
  def test_check_all_3
    NestedSetWithStringScope.update_all("lft = lft + 2", "lft > 11 AND root_id = 101")
    NestedSetWithStringScope.update_all("rgt = rgt + 2", "lft > 11 AND root_id = 101")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all} 
  end
  
  def test_check_all_4
    ns = NestedSetWithStringScope.create(:root_id => 101) # virtual root
    assert_nothing_raised {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.update_all("rgt = rgt + 2, lft = lft + 2", "id = #{ns.id}") # create a gap between virtual roots
    assert_nothing_raised {ns.check_subtree}
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all} 
  end
  
  def test_renumber_all
    NestedSetWithStringScope.update_all("lft = NULL, rgt = NULL")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.renumber_all    
    assert_nothing_raised(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.update_all("lft = 1, rgt = 2")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.renumber_all    
    assert_nothing_raised(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
  end
  
  def test_sql_for
    assert_equal("1 != 1", Category.sql_for([]))
    c = Category.new
    assert_equal("1 != 1", Category.sql_for(c))
    assert_equal("1 != 1", Category.sql_for([c]))
    c.save
    assert_equal("((mixins.lft BETWEEN 1 AND 2))", Category.sql_for(c))
    assert_equal("((mixins.lft BETWEEN 1 AND 2))", Category.sql_for([c]))
    assert_equal("((mixins.lft BETWEEN 1 AND 20))", NestedSetWithStringScope.sql_for(101))
    assert_equal("((mixins.lft BETWEEN 1 AND 20) OR (mixins.lft BETWEEN 4 AND 11))", NestedSetWithStringScope.sql_for([101, set2(3)]))
    assert_equal("((mixins.lft BETWEEN 5 AND 6) OR (mixins.lft BETWEEN 7 AND 8) OR (mixins.lft BETWEEN 9 AND 10))", NestedSetWithStringScope.sql_for(set2(3).children))
  end
  
  
  ##########################################
  # CALLBACK TESTS
  ##########################################
  # If we change behavior of virtual roots, this test may change
  def test_before_create
    ns = NestedSetWithSymbolScope.create(:root_id => 1234)
    assert_equal(1, ns.lft)
    assert_equal(2, ns.rgt)
    ns = NestedSetWithSymbolScope.create(:root_id => 1234)
    assert_equal(3, ns.lft)
    assert_equal(4, ns.rgt)
  end
  
  # test pruning a branch. only works if we allow the deletion of nodes with children
  def test_destroy
    big_tree = NestedSetWithStringScope.find(4001)
    
    # Make sure we have the right one
    assert_equal(3, big_tree.direct_children.length)
    assert_equal(10, big_tree.full_set.length)
    
    NestedSetWithStringScope.find(4005).destroy

    big_tree = NestedSetWithStringScope.find(4001)
    
    assert_equal(7, big_tree.full_set.length)
    assert_equal(2, big_tree.direct_children.length)
    
    assert_equal(1, NestedSetWithStringScope.find(4001).lft)
    assert_equal(2, NestedSetWithStringScope.find(4002).lft)
    assert_equal(3, NestedSetWithStringScope.find(4003).lft)
    assert_equal(4, NestedSetWithStringScope.find(4003).rgt)
    assert_equal(5, NestedSetWithStringScope.find(4004).lft)
    assert_equal(6, NestedSetWithStringScope.find(4004).rgt)
    assert_equal(7, NestedSetWithStringScope.find(4002).rgt)
    assert_equal(8, NestedSetWithStringScope.find(4008).lft)
    assert_equal(9, NestedSetWithStringScope.find(4009).lft)
    assert_equal(10, NestedSetWithStringScope.find(4009).rgt)
    assert_equal(11, NestedSetWithStringScope.find(4010).lft)
    assert_equal(12, NestedSetWithStringScope.find(4010).rgt)
    assert_equal(13, NestedSetWithStringScope.find(4008).rgt)
    assert_equal(14, NestedSetWithStringScope.find(4001).rgt)
  end
  
  def test_destroy_2
    assert_nothing_raised {set2(1).check_subtree}
    assert set2(10).destroy    
    assert_nothing_raised {set2(1).reload.check_subtree}
    assert set2(9).children.empty?
    assert set2(9).destroy
    assert_equal 15, set2(4).rgt
    assert_nothing_raised {set2(1).reload.check_subtree}
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_destroy_3
    assert set2(3).destroy
    assert_equal(2, set2(1).children.size)
    assert_equal(0, NestedSetWithStringScope.find(:all, :conditions => "id > 104 and id < 108").size)
    assert_equal(6, set2(1).full_set.size)
    assert_equal(3, set2(2).rgt)
    assert_equal(4, set2(4).lft)
    assert_equal(12, set2(1).rgt)
    assert_nothing_raised {set2(1).check_subtree}
  end
  
  def test_destroy_root
    NestedSetWithStringScope.find(4001).destroy
    assert_equal(0, NestedSetWithStringScope.count(:conditions => "root_id = 42"))
  end            
  
  def test_destroy_dependent
    NestedSetWithStringScope.acts_as_nested_set_options[:dependent] = :destroy
    
    big_tree = NestedSetWithStringScope.find(4001)
    
    # Make sure we have the right one
    assert_equal(3, big_tree.direct_children.length)
    assert_equal(10, big_tree.full_set.length)
    
    NestedSetWithStringScope.find(4005).destroy

    big_tree = NestedSetWithStringScope.find(4001)
    
    assert_equal(7, big_tree.full_set.length)
    assert_equal(2, big_tree.direct_children.length)
    
    assert_equal(1, NestedSetWithStringScope.find(4001).lft)
    assert_equal(2, NestedSetWithStringScope.find(4002).lft)
    assert_equal(3, NestedSetWithStringScope.find(4003).lft)
    assert_equal(4, NestedSetWithStringScope.find(4003).rgt)
    assert_equal(5, NestedSetWithStringScope.find(4004).lft)
    assert_equal(6, NestedSetWithStringScope.find(4004).rgt)
    assert_equal(7, NestedSetWithStringScope.find(4002).rgt)
    assert_equal(8, NestedSetWithStringScope.find(4008).lft)
    assert_equal(9, NestedSetWithStringScope.find(4009).lft)
    assert_equal(10, NestedSetWithStringScope.find(4009).rgt)
    assert_equal(11, NestedSetWithStringScope.find(4010).lft)
    assert_equal(12, NestedSetWithStringScope.find(4010).rgt)
    assert_equal(13, NestedSetWithStringScope.find(4008).rgt)
    assert_equal(14, NestedSetWithStringScope.find(4001).rgt)  
  end
  
  ##########################################
  # QUERY METHOD TESTS
  ##########################################
  def set(id) NestedSet.find(3000 + id) end # helper method
  
  def set2(id) NestedSetWithStringScope.find(100 + id) end # helper method
  
  def test_root?
    assert NestedSetWithStringScope.find(4001).root?
    assert !NestedSetWithStringScope.find(4002).root?
  end
  
  def test_child?
    assert !NestedSetWithStringScope.find(4001).child?
    assert NestedSetWithStringScope.find(4002).child?    
  end
  
  # Deprecated, delete this test when we nuke the method
  def test_unknown?
    assert !NestedSetWithStringScope.find(4001).unknown?
    assert !NestedSetWithStringScope.find(4002).unknown?        
  end
  
  # Test the <=> method implicitly
  def test_comparison
    ar = NestedSetWithStringScope.find(:all, :conditions => "root_id = 42", :order => "lft")
    ar2 = NestedSetWithStringScope.find(:all, :conditions => "root_id = 42", :order => "rgt")
    assert_not_equal(ar, ar2)
    assert_equal(ar, ar2.sort)
  end
  
  def test_root
    assert_equal(NestedSetWithStringScope.find(4001), NestedSetWithStringScope.find(4007).root)
    assert_equal(set2(1), set2(8).root)
    assert_equal(set2(1), set2(1).root)
    # test virtual roots
    c1, c2, c3 = Category.create, Category.create, Category.create
    c3.move_to_child_of(c2)
    assert_equal(c2, c3.root)
  end
  
  def test_roots
    assert_equal([set2(1)], set2(8).roots)
    assert_equal([set2(1)], set2(1).roots)
    assert_equal(NestedSet.find(:all, :conditions => "id > 3000 AND id < 4000").size, set(1).roots.size)
  end
  
  def test_parent
    ns = NestedSetWithStringScope.create(:root_id => 45)
    assert_equal(nil, ns.parent)
    assert ns.save
    assert_equal(nil, ns.parent)
    assert_equal(set2(1), set2(2).parent)
    assert_equal(set2(3), set2(7).parent)
  end
  
  def test_ancestors
    assert_equal([], set2(1).ancestors)
    assert_equal([set2(1), set2(4), set2(9)], set2(10).ancestors)
  end
  
  def test_self_and_ancestors
    assert_equal([set2(1)], set2(1).self_and_ancestors)
    assert_equal([set2(1), set2(4), set2(8)], set2(8).self_and_ancestors)
    assert_equal([set2(1), set2(4), set2(9), set2(10)], set2(10).self_and_ancestors)
  end
  
  def test_siblings
    assert_equal([], set2(1).siblings)
    assert_equal([set2(2), set2(4)], set2(3).siblings)
  end
  
  def test_first_sibling
    assert set2(2).first_sibling?
    assert_equal(set2(2), set2(2).first_sibling)
    assert_equal(set2(2), set2(3).first_sibling)
    assert_equal(set2(2), set2(4).first_sibling)
  end
  
  def test_last_sibling
    assert set2(4).last_sibling?
    assert_equal(set2(4), set2(2).last_sibling)
    assert_equal(set2(4), set2(3).last_sibling)
    assert_equal(set2(4), set2(4).last_sibling)
  end
  
  def test_previous_siblings
    assert_equal([], set2(2).previous_siblings)
    assert_equal([set2(2)], set2(3).previous_siblings)
    assert_equal([set2(3), set2(2)], set2(4).previous_siblings)
  end
  
  def test_previous_sibling
    assert_equal(nil, set2(2).previous_sibling)
    assert_equal(set2(2), set2(3).previous_sibling)
    assert_equal(set2(3), set2(4).previous_sibling)
    assert_equal([set2(3), set2(2)], set2(4).previous_sibling(2))
  end
  
  def test_next_siblings
    assert_equal([], set2(4).next_siblings)
    assert_equal([set2(4)], set2(3).next_siblings)
    assert_equal([set2(3), set2(4)], set2(2).next_siblings)
  end
  
  def test_next_sibling
    assert_equal(nil, set2(4).next_sibling)
    assert_equal(set2(4), set2(3).next_sibling)
    assert_equal(set2(3), set2(2).next_sibling)
    assert_equal([set2(3), set2(4)], set2(2).next_sibling(2))
  end
  
  def test_self_and_siblings
    assert_equal([set2(1)], set2(1).self_and_siblings)
    assert_equal([set2(2), set2(3), set2(4)], set2(3).self_and_siblings)    
  end
  
  def test_level
    assert_equal(0, set2(1).level)
    assert_equal(1, set2(3).level)
    assert_equal(3, set2(10).level)
  end
  
  def test_all_children_count
    assert_equal(0, set2(10).all_children_count)
    assert_equal(1, set2(3).level)
    assert_equal(3, set2(10).level)    
  end
  
  def test_full_set
    assert_equal(NestedSetWithStringScope.find(:all, :conditions => "root_id = 101", :order => "lft"), set2(1).full_set)
    new_ns = NestedSetWithStringScope.new(:root_id => 101)
    assert_equal([new_ns], new_ns.full_set)
    assert_equal([set2(4), set2(8), set2(9), set2(10)], set2(4).full_set)
    assert_equal([set2(2)], set2(2).full_set)
    assert_equal([set2(2)], set2(2).full_set(:exclude => nil))
    assert_equal([set2(2)], set2(2).full_set(:exclude => []))
    assert_equal([], set2(1).full_set(:exclude => 101))
    assert_equal([], set2(1).full_set(:exclude => set2(1)))
    ns = NestedSetWithStringScope.create(:root_id => 234)
    assert_equal([], ns.full_set(:exclude => ns))
    assert_equal([set2(4), set2(8), set2(9)], set2(4).full_set(:exclude => set2(10)))
    assert_equal([set2(4), set2(8)], set2(4).full_set(:exclude => set2(9))) 
  end
    
  def test_all_children
    assert_equal(NestedSetWithStringScope.find(:all, :conditions => "root_id = 101 AND id > 101", :order => "lft"), set2(1).all_children)
    assert_equal([], NestedSetWithStringScope.new(:root_id => 101).all_children)
    assert_equal([set2(8), set2(9), set2(10)], set2(4).all_children)
    assert_equal([set2(8), set2(9)], set2(4).all_children(:exclude => set2(10)))
    assert_equal([set2(8)], set2(4).all_children(:exclude => set2(9)))
    assert_equal([set2(2), set2(4), set2(8)], set2(1).all_children(:exclude => [set2(9), 103]))
    assert_equal([set2(2), set2(4), set2(8)], set2(1).all_children(:exclude => [set2(9), 103, 106]))
  end
  
  def test_children
    assert_equal([], set2(10).children) 
    assert_equal([], set(1).children) 
    assert_equal([set2(2), set2(3), set2(4)], set2(1).children) 
    assert_equal([set2(5), set2(6), set2(7)], set2(3).children) 
    assert_equal([NestedSetWithStringScope.find(4006), NestedSetWithStringScope.find(4007)], NestedSetWithStringScope.find(4005).children) 
  end
  
  def test_children_count
    assert_equal(0, set2(10).children_count) 
    assert_equal(3, set2(1).children_count)
  end
  
  def test_leaves
    assert_equal([set2(10)], set2(9).leaves)
    assert_equal([set2(10)], set2(10).leaves)
    assert_equal([set2(2), set2(5), set2(6), set2(7), set2(8), set2(10)], set2(1).leaves)
  end
  
  def test_leaves_count
    assert_equal(1, set2(10).leaves_count)
    assert_equal(1, set2(9).leaves_count)
    assert_equal(6, set2(1).leaves_count)
  end

  ##########################################
  # CASTING RESULT TESTS
  ##########################################
  
  def test_recurse_result_set
    result = []
    NestedSetWithStringScope.recurse_result_set(set2(1).full_set) do |node, level|
      result << [level, node.id]
    end
    expected = [[0, 101], [1, 102], [1, 103], [2, 105], [2, 106], [2, 107], [1, 104], [2, 108], [2, 109], [3, 110]]
    assert_equal expected, result
  end
  
  def test_disjointed_result_set
    result_set = set2(1).full_set(:conditions => { :type => 'NestedSetWithStringScope' })
    result = []
    NestedSetWithStringScope.recurse_result_set(result_set) do |node, level|
      result << [level, node.id]
    end
    expected = [[0, 102], [0, 104], [0, 105], [0, 106], [0, 107], [0, 110]]
    assert_equal expected, result
  end
  
  def test_result_to_array
    result = NestedSetWithStringScope.result_to_array(set2(1).full_set) do |node, level|
      { :id => node.id, :level => level }
    end
    expected = [{:level=>0, :children=>[{:level=>1, :id=>102}, {:level=>1, 
      :children=>[{:level=>2, :id=>105}, {:level=>2, :id=>106}, {:level=>2, :id=>107}], :id=>103}, {:level=>1, 
      :children=>[{:level=>2, :id=>108}, {:level=>2, :children=>[{:level=>3, :id=>110}], :id=>109}], :id=>104}], :id=>101}]
    assert_equal expected, result
  end
  
  def test_result_to_array_with_method_calls
    result = NestedSetWithStringScope.result_to_array(set2(1).full_set, :only => [:id], :methods => [:children_count])
    expected = [{:children=>[{:children_count=>0, :id=>102}, {:children=>[{:children_count=>0, :id=>105}, {:children_count=>0, :id=>106}, 
      {:children_count=>0, :id=>107}], :children_count=>3, :id=>103}, {:children=>[{:children_count=>0, :id=>108}, {:children=>[{:children_count=>0, :id=>110}], 
      :children_count=>1, :id=>109}], :children_count=>2, :id=>104}], :children_count=>3, :id=>101}]
    assert_equal expected, result
  end
  
  def test_disjointed_result_to_array
    result_set = set2(1).full_set(:conditions => { :type => 'NestedSetWithStringScope' })
    result = NestedSetWithStringScope.result_to_array(result_set) do |node, level|
      { :id => node.id, :level => level }
    end
    expected = [{:level=>0, :id=>102}, {:level=>0, :id=>104}, {:level=>0, :id=>105}, {:level=>0, :id=>106}, {:level=>0, :id=>107}, {:level=>0, :id=>110}]
    assert_equal expected, result
  end
  
  def test_result_to_array_flat
    result = NestedSetWithStringScope.result_to_array(set2(1).full_set, :nested => false) do |node, level|
      { :id => node.id, :level => level }
    end
    expected = [{:level=>0, :id=>101}, {:level=>0, :id=>103}, {:level=>0, :id=>106}, {:level=>0, :id=>104}, {:level=>0, :id=>109}, 
      {:level=>0, :id=>102}, {:level=>0, :id=>105}, {:level=>0, :id=>107}, {:level=>0, :id=>108}, {:level=>0, :id=>110}]
    assert_equal expected, result
  end
  
  def test_result_to_xml
    result = NestedSetWithStringScope.result_to_xml(set2(3).full_set, :record => 'node', :dasherize => false, :only => [:id]) do |options, subnode|
       options[:builder].tag!('type', subnode[:type])
    end
    expected = '<?xml version="1.0" encoding="UTF-8"?>
<nodes>
  <node>
    <id type="integer">103</id>
    <type>NS2</type>
    <children>
      <node>
        <id type="integer">105</id>
        <type>NestedSetWithStringScope</type>
        <children>
        </children>
      </node>
      <node>
        <id type="integer">106</id>
        <type>NestedSetWithStringScope</type>
        <children>
        </children>
      </node>
      <node>
        <id type="integer">107</id>
        <type>NestedSetWithStringScope</type>
        <children>
        </children>
      </node>
    </children>
  </node>
</nodes>'
    assert_equal expected, result.strip
  end
  
  def test_disjointed_result_to_xml
    result_set = set2(1).full_set(:conditions => ['type IN(?)', ['NestedSetWithStringScope', 'NS2']])
    result = NestedSetWithStringScope.result_to_xml(result_set, :only => [:id])
    # note how nesting is preserved where possible; this is not always what you want though, 
    # so you can force a flattened set with :nested => false instead (see below)
    expected = '<?xml version="1.0" encoding="UTF-8"?>
<nodes>
  <nested-set-with-string-scope>
    <id type="integer">102</id>
    <children>
    </children>
  </nested-set-with-string-scope>
  <ns2>
    <id type="integer">103</id>
    <children>
      <nested-set-with-string-scope>
        <id type="integer">105</id>
        <children>
        </children>
      </nested-set-with-string-scope>
      <nested-set-with-string-scope>
        <id type="integer">106</id>
        <children>
        </children>
      </nested-set-with-string-scope>
      <nested-set-with-string-scope>
        <id type="integer">107</id>
        <children>
        </children>
      </nested-set-with-string-scope>
    </children>
  </ns2>
  <nested-set-with-string-scope>
    <id type="integer">104</id>
    <children>
      <ns2>
        <id type="integer">108</id>
        <children>
        </children>
      </ns2>
    </children>
  </nested-set-with-string-scope>
</nodes>'
    assert_equal expected, result.strip
  end
  
  def test_result_to_xml_flat
    result = NestedSetWithStringScope.result_to_xml(set2(3).full_set, :record => 'node', :dasherize => false, :only => [:id], :nested => false)
    expected = '<?xml version="1.0" encoding="UTF-8"?>
<nodes>
  <node>
    <id type="integer">103</id>
  </node>
  <node>
    <id type="integer">105</id>
  </node>
  <node>
    <id type="integer">106</id>
  </node>
  <node>
    <id type="integer">107</id>
  </node>
</nodes>'
    assert_equal expected, result.strip
  end
  
  def test_result_to_attribute_based_xml
    result = NestedSetWithStringScope.result_to_attributes_xml(set2(1).full_set, :record => 'node', :only => [:id, :parent_id])
    expected = '<?xml version="1.0" encoding="UTF-8"?>
<node id="101" parent_id="0">
  <node id="102" parent_id="101"/>
  <node id="103" parent_id="101">
    <node id="105" parent_id="103"/>
    <node id="106" parent_id="103"/>
    <node id="107" parent_id="103"/>
  </node>
  <node id="104" parent_id="101">
    <node id="108" parent_id="104"/>
    <node id="109" parent_id="104">
      <node id="110" parent_id="109"/>
    </node>
  </node>
</node>'
    assert_equal expected, result.strip
  end
  
  def test_result_to_attribute_based_xml_flat
    result = NestedSetWithStringScope.result_to_attributes_xml(set2(1).full_set, :only => [:id], :nested => false, :skip_instruct => true)
    expected = '<ns1 id="101"/>
<ns2 id="103"/>
<nested_set_with_string_scope id="106"/>
<nested_set_with_string_scope id="104"/>
<ns1 id="109"/>
<nested_set_with_string_scope id="102"/>
<nested_set_with_string_scope id="105"/>
<nested_set_with_string_scope id="107"/>
<ns2 id="108"/>
<nested_set_with_string_scope id="110"/>'
    assert_equal expected, result.strip
  end
  
  ##########################################
  # WITH_SCOPE QUERY TESTS
  ##########################################
  
  def test_filtered_full_set
    result_set = set2(1).full_set(:conditions => { :type => 'NestedSetWithStringScope' })
    assert_equal [102, 105, 106, 107, 104, 110], result_set.map(&:id)
  end
  
  def test_reverse_result_set
    result_set = set2(1).full_set(:reverse => true)  
    assert_equal [101, 104, 109, 110, 108, 103, 107, 106, 105, 102], result_set.map(&:id)
    # NestedSetWithStringScope.recurse_result_set(result_set) { |node, level| puts "#{'--' * level}#{node.id}" }
  end
  
  def test_reordered_full_set
    result_set = set2(1).full_set(:order => 'id DESC')
    assert_equal [110, 109, 108, 107, 106, 105, 104, 103, 102, 101], result_set.map(&:id)
  end
  
  def test_filtered_siblings
    node = set2(2)
    result_set = node.siblings(:conditions => { :type => node[:type] })
    assert_equal [104], result_set.map(&:id)
  end
  
  def test_include_option_with_full_set
    result_set = set2(3).full_set(:include => :parent_node)
    assert_equal [[103, 101], [105, 103], [106, 103], [107, 103]], result_set.map { |n| [n.id, n.parent_node.id] }
  end

  ##########################################
  # FIND UNTIL/THROUGH METHOD TESTS
  ##########################################

  def test_ancestors_and_self_through
    result = set2(10).ancestors_and_self_through(set2(4))
    assert_equal [104, 109, 110], result.map(&:id)
    result = set2(10).ancestors_through(set2(4))
    assert_equal [104, 109], result.map(&:id)
  end
  
  def test_full_set_through
    result = set2(4).full_set_through(set2(10))
    assert_equal [104, 108, 109, 110], result.map(&:id)
  end

  def test_all_children_through
    result = set2(4).all_children_through(set2(10))
    assert_equal [108, 109, 110], result.map(&:id)
  end
  
  def test_siblings_through
    result = set2(5).self_and_siblings_through(set2(7))
    assert_equal [105, 106, 107], result.map(&:id)
    result = set2(7).siblings_through(set2(5))
    assert_equal [105, 106], result.map(&:id)
  end
  
  ##########################################
  # FIND CHILD BY ID METHOD TESTS
  ##########################################
  
  def test_child_by_id
    assert_equal set2(6), set2(3).child_by_id(set2(6).id)
    assert_nil set2(3).child_by_id(set2(8).id)
  end
  
  def test_child_of
    assert  set2(6).child_of?(set2(3))
    assert !set2(8).child_of?(set2(3))
    assert set2(6).child_of?(set2(3), :conditions => '1 = 1')
  end
  
  def test_direct_child_by_id
    assert_equal set2(9), set2(4).direct_child_by_id(set2(9).id)
    assert_nil set2(4).direct_child_by_id(set2(10).id)
  end
  
  def test_direct_child_of
    assert set2(9).direct_child_of?(set2(4))
    assert !set2(10).direct_child_of?(set2(4))
    assert set2(9).direct_child_of?(set2(4), :conditions => '1 = 1')
  end
  
  ##########################################
  # INDEX-CHECKING METHOD TESTS
  ##########################################
  def test_check_subtree
    root = set2(1)
    assert_nothing_raised {root.check_subtree}
    # need to use update_all to get around attr_protected
    NestedSetWithStringScope.update_all("rgt = #{root.lft + 1}", "id = #{root.id}")
    assert_raise(ActiveRecord::ActiveRecordError) {root.reload.check_subtree}
    assert_nothing_raised {set2(4).check_subtree}
    NestedSetWithStringScope.update_all("lft = 17", "id = 110")
    assert_raise(ActiveRecord::ActiveRecordError) {set2(4).reload.check_subtree}
    NestedSetWithStringScope.update_all("rgt = 18", "id = 110")
    assert_nothing_raised {set2(10).check_subtree}
    NestedSetWithStringScope.update_all("rgt = NULL", "id = 4002")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.find(4001).reload.check_subtree}
    # this method receives lots of additional testing through tests of check_full_tree and check_all
  end
  
  def test_check_full_tree
    assert_nothing_raised {set2(1).check_full_tree}
    assert_nothing_raised {NestedSetWithStringScope.find(4006).check_full_tree}
    NestedSetWithStringScope.update_all("rgt = NULL", "id = 4002")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.find(4006).check_full_tree}
    NestedSetWithStringScope.update_all("rgt = 0", "id = 4001")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.find(4006).check_full_tree}
    NestedSetWithStringScope.update_all("rgt = rgt + 1", "id > 101")
    NestedSetWithStringScope.update_all("lft = lft + 1", "id > 101")
    assert_raise(ActiveRecord::ActiveRecordError) {set2(4).check_full_tree}
  end
  
  def test_check_full_tree_orphan
    assert_raise(ActiveRecord::RecordNotFound) {NestedSetWithStringScope.find(99)} # make sure ID 99 doesn't exist
    ns = NestedSetWithStringScope.create(:root_id => 101)
    NestedSetWithStringScope.update_all("parent_id = 99", "id = #{ns.id}")
    assert_raise(ActiveRecord::ActiveRecordError) {set2(3).check_full_tree}
  end
  
  def test_check_full_tree_endless_loop
    ns = NestedSetWithStringScope.create(:root_id => 101)
    NestedSetWithStringScope.update_all("parent_id = #{ns.id}", "id = #{ns.id}")
    assert_raise(ActiveRecord::ActiveRecordError) {set2(6).check_full_tree}
  end
  
  def test_check_full_tree_virtual_roots
    a = Category.create    
    b = Category.create
    
    assert_nothing_raised {a.check_full_tree}
    Category.update_all("rgt = rgt + 2, lft = lft + 2", "id = #{b.id}") # create a gap between virtual roots
    assert_raise(ActiveRecord::ActiveRecordError) {a.check_full_tree}
  end
  
  # see also the tests of check_all under 'class method tests'
    
  ##########################################
  # INDEX-ALTERING (UPDATE) METHOD TESTS
  ##########################################
  def test_move_to_left_of # this method undergoes additional testing elsewhere
    set2(2).move_to_left_of(set2(3)) # should cause no change
    assert_equal(2, set2(2).lft)
    assert_equal(4, set2(3).lft)
    assert_nothing_raised {NestedSetWithStringScope.check_all}
    set2(3).move_to_left_of(set2(2))
    assert_equal(9, set2(3).rgt)
    set2(2).move_to_left_of(set2(3))
    assert_equal(2, set2(2).lft)
    assert_nothing_raised {NestedSetWithStringScope.check_all}
    set2(3).move_to_left_of(102) # pass an ID instead
    assert_equal(2, set2(3).lft)
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_move_to_right_of # this method undergoes additional testing elsewhere
    set2(3).move_to_right_of(set2(2)) # should cause no change
    set2(4).move_to_right_of(set2(3)) # should cause no change
    assert_equal(11, set2(3).rgt)
    assert_equal(19, set2(4).rgt)
    assert_nothing_raised {NestedSetWithStringScope.check_all}
    set2(3).move_to_right_of(set2(4))
    assert_equal(19, set2(3).rgt)
    set2(4).move_to_right_of(set2(3))
    assert_equal(4, set2(3).lft)
    assert_nothing_raised {NestedSetWithStringScope.check_all}
    set2(3).move_to_right_of(104) # pass an ID instead
    assert_equal(4, set2(4).lft)
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_adding_children
    assert(set(1).unknown?)
    assert(set(2).unknown?)
    set(1).add_child set(2)
    
    # Did we maintain adding the parent_ids?
    assert(set(1).root?)
    assert(set(2).child?)
    assert(set(2).parent_id == set(1).id)
    
    # Check boundaries
    assert_equal(set(1).lft, 1)
    assert_equal(set(2).lft, 2)
    assert_equal(set(2).rgt, 3)
    assert_equal(set(1).rgt, 4)
    
    # Check children cound
    assert_equal(set(1).all_children_count, 1)
    
    set(1).add_child set(3)
    
    #check boundries
    assert_equal(set(1).lft, 1)
    assert_equal(set(2).lft, 2)
    assert_equal(set(2).rgt, 3)
    assert_equal(set(3).lft, 4)
    assert_equal(set(3).rgt, 5)
    assert_equal(set(1).rgt, 6)
    
    # How is the count looking?
    assert_equal(set(1).all_children_count, 2)

    set(2).add_child set(4)

    # boundries
    assert_equal(set(1).lft, 1)
    assert_equal(set(2).lft, 2)
    assert_equal(set(4).lft, 3)
    assert_equal(set(4).rgt, 4)
    assert_equal(set(2).rgt, 5)
    assert_equal(set(3).lft, 6)
    assert_equal(set(3).rgt, 7)
    assert_equal(set(1).rgt, 8)
    
    # Children count
    assert_equal(set(1).all_children_count, 3)
    assert_equal(set(2).all_children_count, 1)
    assert_equal(set(3).all_children_count, 0)
    assert_equal(set(4).all_children_count, 0)
    
    set(2).add_child set(5)
    set(4).add_child set(6)
    
    assert_equal(set(2).all_children_count, 3)

    # Children accessors
    assert_equal(set(1).full_set.length, 6)
    assert_equal(set(2).full_set.length, 4)
    assert_equal(set(4).full_set.length, 2)
    
    assert_equal(set(1).all_children.length, 5)
    assert_equal(set(6).all_children.length, 0)
    
    assert_equal(set(1).direct_children.length, 2)

    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end

  def test_common_usage
    mixins(:set_1).add_child(mixins(:set_2))
    assert_equal(1, mixins(:set_1).direct_children.length)

    mixins(:set_2).add_child(mixins(:set_3))                      
    assert_equal(1, mixins(:set_1).direct_children.length)     
    
    # Local cache is now out of date!
    # Problem: the update_alls update all objects up the tree
    mixins(:set_1).reload
    assert_equal(2, mixins(:set_1).all_children.length)              
    
    assert_equal(1, mixins(:set_1).lft)
    assert_equal(2, mixins(:set_2).lft)
    assert_equal(3, mixins(:set_3).lft)
    assert_equal(4, mixins(:set_3).rgt)
    assert_equal(5, mixins(:set_2).rgt)
    assert_equal(6, mixins(:set_1).rgt)  
    assert(mixins(:set_1).root?)
                  
    begin
      mixins(:set_4).add_child(mixins(:set_1))
      fail
    rescue
    end
    
    assert_equal(2, mixins(:set_1).all_children.length)
    mixins(:set_1).add_child mixins(:set_4)
    assert_equal(3, mixins(:set_1).all_children.length)
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_move_to_child_of_1
    bill = NestedSetWithStringScope.new(:root_id => 101, :pos => 2)
    assert_raise(ActiveRecord::ActiveRecordError) { bill.move_to_child_of(set2(1)) }    
    assert_raise(ActiveRecord::ActiveRecordError) { set2(1).move_to_child_of(set2(1)) }    
    assert_raise(ActiveRecord::ActiveRecordError) { set2(4).move_to_child_of(set2(9)) }    
    assert bill.save
    assert_nothing_raised {set2(1).reload.check_subtree}
    assert bill.move_to_left_of(set2(3))
    assert_equal set2(1), bill.parent
    assert_equal 4, bill.lft
    assert_equal 5, bill.rgt
    assert_equal 3, set2(2).reload.rgt
    assert_equal 6, set2(3).reload.lft
    assert_equal 22, set2(1).reload.rgt
    assert_nothing_raised {set2(1).reload.check_subtree}
    assert_nothing_raised {NestedSetWithStringScope.check_all}
    set2(9).move_to_child_of(101) # pass an ID instead
    assert set2(1).children.include?(set2(9))
    assert_equal(18, set2(9).lft) # to the right of existing children?
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_move_to_child_of_2
    bill = NestedSetWithStringScope.new(:root_id => 101)
    assert_nothing_raised {set2(1).check_subtree}
    assert bill.save
    assert bill.move_to_child_of(set2(10))
    assert_equal set2(10), bill.parent
    assert_equal 17, bill.lft
    assert_equal 18, bill.rgt
    assert_equal 16, set2(10).reload.lft
    assert_equal 19, set2(10).reload.rgt
    assert_equal 15, set2(9).reload.lft
    assert_equal 20, set2(9).reload.rgt
    assert_equal 21, set2(4).reload.rgt
    assert_nothing_raised {set2(9).reload.check_subtree}
    assert_nothing_raised {set2(4).reload.check_subtree}
    assert_nothing_raised {set2(1).reload.check_subtree}
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_move_to_child_of_3
    bill = NestedSetWithStringScope.new(:root_id => 101)
    assert bill.save
    assert bill.move_to_child_of(set2(3))
    assert_equal(11, bill.lft) # to the right of existing children?
    assert_nothing_raised {set2(1).reload.check_subtree}
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_move_1
    set2(4).move_to_child_of(set2(3))
    assert_equal(set2(3), set2(4).reload.parent)
    assert_equal(1, set2(1).reload.lft)
    assert_equal(20, set2(1).reload.rgt)
    assert_equal(4, set2(3).reload.lft)
    assert_equal(19, set2(3).reload.rgt)
    assert_nothing_raised {set2(1).reload.check_subtree}
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_move_2
    initial = set2(1).full_set
    assert_raise(ActiveRecord::ActiveRecordError) { set2(3).move_to_child_of(set2(6)) } # can't set a current child as the parent-- creates a loop
    assert_raise(ActiveRecord::ActiveRecordError) { set2(3).move_to_child_of(set2(3)) }
    set2(2).move_to_child_of(set2(5))
    set2(4).move_to_child_of(set2(2))
    set2(10).move_to_right_of(set2(3))
    
    assert_equal 105, set2(2).parent_id
    assert_equal 102, set2(4).parent_id
    assert_equal 101, set2(10).parent_id
    set2(3).reload
    set2(10).reload
    assert_equal 19, set2(10).rgt
    assert_equal 17, set2(3).rgt
    assert_equal 2, set2(3).lft
    set2(1).reload
    assert_nothing_raised {set2(1).check_subtree}
    set2(4).move_to_right_of(set2(3))
    set2(10).move_to_child_of(set2(9))
    set2(2).move_to_left_of(set2(3))
    
    # now everything should be back where it started-- check against initial
    final = set2(1).reload.full_set
    assert_equal(initial, final)
    for i in 0..9
      assert_equal(initial[i]['parent_id'], final[i]['parent_id'])
      assert_equal(initial[i]['lft'], final[i]['lft'])
      assert_equal(initial[i]['rgt'], final[i]['rgt'])
    end
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_scope_enforcement # prevent moves between trees
    assert_raise(ActiveRecord::ActiveRecordError) { set(3).move_to_child_of(set2(6)) }
    ns = NestedSetWithStringScope.create(:root_id => 214)
    assert_raise(ActiveRecord::ActiveRecordError) { ns.move_to_child_of(set2(1)) }
  end
  
  ##########################################
  # ACTS_AS_LIST-LIKE BEHAVIOUR TESTS
  ##########################################  
  
  def test_swap
    set2(5).swap(set2(7))
    assert_equal [107, 106, 105], set2(3).children.map(&:id)   
    assert_nothing_raised {set2(3).check_full_tree}
    assert_raise(ActiveRecord::ActiveRecordError) { set2(3).swap(set2(10)) } # isn't a sibling...
  end
  
  def test_insert_at
    child = NestedSetWithStringScope.create(:root_id => 101)
    child.insert_at(set2(3), :last)
    assert_equal child, set2(3).children.last
    
    child = NestedSetWithStringScope.create(:root_id => 101)
    child.insert_at(set2(3), :first)
    assert_equal child, set2(3).children.first
    
    child = NestedSetWithStringScope.create(:root_id => 101)
    child.insert_at(set2(3), 2)
    assert_equal child, set2(3).children[2]
    
    child = NestedSetWithStringScope.create(:root_id => 101)
    child.insert_at(set2(3), 1000)
    assert_equal child, set2(3).children.last
    
    child = NestedSetWithStringScope.create(:root_id => 101)
    child.insert_at(set2(3), 1)
    assert_equal child, set2(3).children[1]
  end
  
  def test_move_higher
    set2(7).move_higher
    assert_equal [105, 107, 106], set2(3).children.map(&:id)
    set2(7).move_higher
    assert_equal [107, 105, 106], set2(3).children.map(&:id)
    set2(7).move_higher
    assert_equal [107, 105, 106], set2(3).children.map(&:id)
  end
  
  def test_move_lower
    set2(5).move_lower
    assert_equal [106, 105, 107], set2(3).children.map(&:id)
    set2(5).move_lower
    assert_equal [106, 107, 105], set2(3).children.map(&:id)
    set2(5).move_lower
    assert_equal [106, 107, 105], set2(3).children.map(&:id)
  end
  
  def test_move_to_top
    set2(7).move_to_top
    assert_equal [107, 105, 106], set2(3).children.map(&:id)
  end
  
  def test_move_to_bottom
    set2(5).move_to_bottom
    assert_equal [106, 107, 105], set2(3).children.map(&:id)
  end
  
  def test_move_to_position
    set2(7).move_to_position(:first)
    assert_equal [107, 105, 106], set2(3).children.map(&:id)
    set2(7).move_to_position(:last)
    assert_equal [105, 106, 107], set2(3).children.map(&:id)
  end
    
  def test_move_to_position_limits
    set2(7).move_to_position(0)
    assert_equal [107, 105, 106], set2(3).children.map(&:id)
    set2(7).move_to_position(100)
    assert_equal [105, 106, 107], set2(3).children.map(&:id)
  end  
  
  def test_move_to_position_index
    set2(7).move_to_position(0)
    assert_equal [107, 105, 106], set2(3).children.map(&:id)
    set2(7).move_to_position(1)
    assert_equal [105, 107, 106], set2(3).children.map(&:id)
    set2(7).move_to_position(2)
    assert_equal [105, 106, 107], set2(3).children.map(&:id)
    set2(5).move_to_position(2)
    assert_equal [106, 107, 105], set2(3).children.map(&:id)
  end
  
  def test_scoped_move_to_position
    set2(7).move_to_position(0, :conditions => { :id => [105, 106, 107] })
    assert_equal [107, 105, 106], set2(3).children.map(&:id)
    set2(7).move_to_position(1, :conditions => { :id => [105, 107] })
    assert_equal [105, 107, 106], set2(3).children.map(&:id)
    set2(7).move_to_position(1, :conditions => { :id => [106, 107] })
    assert_equal [105, 106, 107], set2(3).children.map(&:id)  
  end
  
  def test_reorder_children     
    assert_equal [105], set2(3).reorder_children(107, 106, 105).map(&:id)
    assert_equal [107, 106, 105], set2(3).children.map(&:id)   
    assert_equal [107, 106], set2(3).reorder_children(106, 105, 107).map(&:id)
    assert_equal [106, 105, 107], set2(3).children.map(&:id)
  end
  
  def test_reorder_children_with_random_samples
    10.times do
      child = NestedSetWithStringScope.create(:root_id => 101)
      child.move_to_child_of set2(3)
    end
    ordered_ids = set2(3).children.map(&:id).sort_by { rand }
    set2(3).reorder_children(ordered_ids)
    assert_equal ordered_ids, set2(3).children.map(&:id)
  end

  def test_reorder_children_with_partial_id_set
    10.times do
      child = NestedSetWithStringScope.create(:root_id => 101)
      child.move_to_child_of set2(3)
    end
    child_ids = set2(3).children.map(&:id)
    set2(3).reorder_children(child_ids.last, child_ids.first)
    ordered_ids = set2(3).children.map(&:id)
    assert_equal ordered_ids.first, child_ids.last
    assert_equal ordered_ids.last, child_ids.first
    assert_equal child_ids[1, -2], ordered_ids[1, -2]
  end
  
  ##########################################
  # RENUMBERING TESTS
  ##########################################
  # see also class method tests of renumber_all
  def test_renumber_full_tree_1
    NestedSetWithStringScope.update_all("lft = NULL, rgt = NULL", "root_id = 101")
    assert_raise(ActiveRecord::ActiveRecordError) {set2(1).check_full_tree}
    set2(1).renumber_full_tree
    set2(1).reload
    assert_equal 1, set2(1).lft
    assert_equal 20, set2(1).rgt
    assert_equal 4, set2(3).lft
    assert_equal 11, set2(3).rgt
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_renumber_full_tree_2
    NestedSetWithStringScope.update_all("lft = lft + 1, rgt = rgt + 1", "root_id = 101")
    assert_raise(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
    set2(1).renumber_full_tree
    assert_nothing_raised(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
    NestedSetWithStringScope.update_all("rgt = 12", "id = 108")
    assert_raise(ActiveRecord::ActiveRecordError) {set2(8).check_subtree}
    set2(8).renumber_full_tree
    assert_nothing_raised(ActiveRecord::ActiveRecordError) {NestedSetWithStringScope.check_all}
  end
  
  
  ##########################################
  # CONCURRENCY TESTS
  ##########################################
  # what happens when multiple objects are being manipulated at the same time?
  def test_concurrent_save
    c1, c2, c3 = Category.create, Category.create, Category.create
    c1.move_to_right_of(c3)
    c2.save
    assert_nothing_raised {Category.check_all}
    
    ns1 = set2(3)
    ns2 = set2(4)
    ns2.move_to_left_of(102) # ns1 is now out-of-date
    ns1.save
    assert_nothing_raised {set2(1).check_subtree}
  end
  
  def test_concurrent_add_add
    c1 = Category.new
    c2 = Category.new
    c1.save
    c2.save
    c3 = Category.new
    c4 = Category.new
    c4.save # now in the opposite order
    c3.save
    assert_nothing_raised {Category.check_all}
  end
  
  def test_concurrent_add_delete
    ns = set2(3)
    new_ns = NestedSetWithStringScope.create(:root_id => 101)
    ns.destroy
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_concurrent_add_move
    ns = set2(3)
    new_ns = NestedSetWithStringScope.create(:root_id => 101)
    ns.move_to_left_of(102)
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_concurrent_delete_add
    ns = set2(3)
    new_ns = NestedSetWithStringScope.new(:root_id => 101)
    ns.destroy
    new_ns.save
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_concurrent_delete_delete
    ns1 = set2(3)
    ns2 = set2(4)
    ns1.destroy
    ns2.destroy
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_concurrent_delete_move
    ns1 = set2(3)
    ns2 = set2(4)
    ns1.destroy
    ns2.move_to_left_of(102)
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_concurrent_move_add
    ns = set2(3)
    new_ns = NestedSetWithStringScope.new(:root_id => 101)
    ns.move_to_left_of(102)
    new_ns.save
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_concurrent_move_delete
    ns1 = set2(3)
    ns2 = set2(4)
    ns2.move_to_left_of(102)
    ns1.destroy
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  def test_concurrent_move_move
    ns1 = set2(3)
    ns2 = set2(4)
    ns1.move_to_left_of(102)
    ns2.move_to_child_of(102)
    assert_nothing_raised {NestedSetWithStringScope.check_all}    
  end
  
  ##########################################
  # CALLBACK TESTS
  ##########################################
  # Because the nested set code relies heavily on callbacks, we
  # want to ensure that we aren't causing problems for user-defined callbacks
  def test_callbacks    
    # 1) Do all user-defined callbacks work?
    $callbacks = []
    ns = NS2.new(:root_id => 101) # NS2 adds symbols to $callbacks when the callbacks fire
    assert_equal([], $callbacks)
    ns.save!
    assert_equal([:before_save, :before_create, :after_create, :after_save], $callbacks)
    $callbacks = []
    ns.pos = 2
    ns.save!
    assert_equal([:before_save, :before_update, :after_update, :after_save], $callbacks)
    $callbacks = []
    ns.destroy
    assert_equal([:before_destroy, :after_destroy], $callbacks)
  end
  
  def test_callbacks2
    # 2) Do our callbacks still work, even when a programmer defines 
    # their own callbacks in the overwriteable style?
    # (the NS2 model defines callbacks in the overwritable style)
    ns = NS2.create(:root_id => 101)
    assert ns.lft != nil && ns.rgt != nil
    child_ns = NS2.create(:root_id => 101)
    child_ns.move_to_child_of(ns)
    id = child_ns.id
    ns.destroy
    assert_equal(nil, NS2.find(:first, :conditions => "id = #{id}"))
    # lots of implicit testing occurs in other test methods
  end

  ##########################################
  # BUG-SPECIFIC TESTS
  ##########################################
  def test_ticket_17
    main = Category.new
    main.save
    sub = Category.new
    sub.save
    sub.move_to_child_of main
    sub.save
    main.save
    
    assert_equal(1, main.all_children_count)
    assert_equal([main, sub], main.full_set)
    assert_equal([sub], main.all_children)
    
    assert_equal(1, main.lft)
    assert_equal(2, sub.lft)
    assert_equal(3, sub.rgt)
    assert_equal(4, main.rgt)
  end
  
  def test_ticket_19
    # this test currently relies on the fact that objects are reloaded at the beginning of the move_to methods
    root = Category.create
    first = Category.create
    second = Category.create
    first.move_to_child_of(root)
    second.move_to_child_of(root)
    
    # now we should have the situation described in the ticket
    assert_nothing_raised {first.move_to_child_of(second)}
    assert_raise(ActiveRecord::ActiveRecordError) {second.move_to_child_of(first)} # try illegal move
    first.move_to_child_of(root) # move it back
    assert_nothing_raised {first.move_to_child_of(second)} # try it the other way-- first is now on the other side of second
    assert_nothing_raised {Category.check_all}
  end
  
  # Note that single-table inheritance recieves extensive implicit testing,
  # because one of the fixture trees contains a hodge-podge of classes.
  def test_ticket_10
    assert_equal(9, set2(1).all_children.size)
    NS2.find(103).move_to_right_of(104)
    assert_equal(4, set2(4).lft)
    assert_equal(10, set2(9).rgt)
    NS2.find(103).destroy
    assert_equal(12, set2(1).rgt)
    assert_equal(6, NestedSetWithStringScope.count(:conditions => "root_id = 101"))
    assert_nothing_raised {NestedSetWithStringScope.check_all}
  end
  
  # the next virtual root was not starting with the correct lft value
  def test_ticket_29
    first = Category.create
    second = Category.create
    Category.renumber_all
    second.reload
    assert_equal(3, second.lft)    
  end
  
end



###################################################################
## Tests that don't pass yet or haven't been finished

## make #destroy set left & rgt to nil? 

#def test_find_insertion_point
#  bill = NestedSetWithStringScope.create(:pos => 2, :root_id => 101)
#  assert_equal 3, bill.find_insertion_point(set2(1))
#  assert_equal 4, bill.find_insertion_point(set2(3))
#  aalfred = NestedSetWithStringScope.create(:pos => 0, :root_id => 101)
#  assert_equal 1, aalfred.find_insertion_point(set2(1))
#  assert_equal 2, aalfred.find_insertion_point(set2(2))
#  assert_equal 12, aalfred.find_insertion_point(set2(4))
#  zed = NestedSetWithStringScope.create(:pos => 99, :root_id => 101)
#  assert_equal 19, zed.find_insertion_point(set2(1))
#  assert_equal 17, zed.find_insertion_point(set2(9))
#  assert_equal 16, zed.find_insertion_point(set2(10))
#  assert_equal 10, set2(4).find_insertion_point(set2(3))
#end
#
