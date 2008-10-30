require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SectionNode do
  before do
    @a = create_section(:parent => root_section, :name => "A")
    @a1 = create_page(:section => @a, :name => "A1")
    @a2 = create_page(:section => @a, :name => "A2")
    @a3 = create_page(:section => @a, :name => "A3")
    @b = create_section(:parent => root_section, :name => "B")
    @b1 = create_page(:section => @b, :name => "B1")
    @b2 = create_page(:section => @b, :name => "B2")
    @b3 = create_page(:section => @b, :name => "B3")    
    
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
  it "should allow nodes to be re-ordered within the same section" do
    @node_a2.move_to(@a, 1)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    #log SectionNode.to_table_without(:created_at, :updated_at)
    @node_a.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    @node_b.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    @node_a1.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 2)
    @node_a2.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a2.id, :position => 1)
    @node_a3.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 3)
    @node_b1.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 1)
    @node_b2.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 2)
    @node_b3.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 3)
  end
  it "should allow nodes to be moved to a different section" do
    @node_a2.move_to(@b, 2)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    log SectionNode.to_table_without(:created_at, :updated_at)
    @node_a.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    @node_b.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    @node_a1.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 1)
    @node_a2.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @a2.id, :position => 2)
    @node_a3.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 2)
    @node_b1.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 1)
    @node_b2.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 3)
    @node_b3.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 4)
  end
  it "should allow nodes to be moved to a beginning of a different section" do
    @node_a2.move_to(@b, 1)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    #log SectionNode.to_table_without(:created_at, :updated_at)
    @node_a.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    @node_b.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    @node_a1.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 1)
    @node_a2.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @a2.id, :position => 1)
    @node_a3.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 2)
    @node_b1.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 2)
    @node_b2.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 3)
    @node_b3.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 4)
  end
  it "should allow nodes to be moved to a end of a different section" do
    @node_a2.move_to(@b, 99)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    #log SectionNode.to_table_without(:created_at, :updated_at)
    @node_a.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    @node_b.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    @node_a1.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 1)
    @node_a2.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @a2.id, :position => 4)
    @node_a3.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 2)
    @node_b1.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 1)
    @node_b2.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 2)
    @node_b3.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 3)
  end
  it "should put at page at the bottom when it's section is changed" do  
    @a2.update_attributes(:section_id => @b.id)
    reset(:node_a, :node_a1, :node_a2, :node_a3, :node_b, :node_b1, :node_b2, :node_b3)
    log SectionNode.to_table_without(:created_at, :updated_at)
    @node_a.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @a.id, :position => 1)
    @node_b.should_meet_expectations(:section_id => root_section.id, :node_type => "Section", :node_id => @b.id, :position => 2)
    @node_a1.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a1.id, :position => 1)
    @node_a2.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @a2.id, :position => 4)
    @node_a3.should_meet_expectations(:section_id => @a.id, :node_type => "Page", :node_id => @a3.id, :position => 2)
    @node_b1.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b1.id, :position => 1)
    @node_b2.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b2.id, :position => 2)
    @node_b3.should_meet_expectations(:section_id => @b.id, :node_type => "Page", :node_id => @b3.id, :position => 3)
  end
  it "should be able to find it's ancestors" do
    root_section.ancestors.should be_empty
    @a.ancestors.should == [root_section]    
    @a1.ancestors.should == [root_section, @a]
  end
end
