require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do
  it "should be able to create categories" do
    @a_type = create_category_type(:name => "A")
    @b_type = create_category_type(:name => "B")
    
    @a = create_category(:name => "A", :category_type => @a_type)
    @a1 = create_category(:name => "A1", :category_type => @a_type, :parent => @a)
    @a1a = create_category(:name => "A1a", :category_type => @a_type, :parent => @a1)
    @a2 = create_category(:name => "A2", :category_type => @a_type, :parent => @a)
    @b = create_category(:name => "B", :category_type => @b_type)    
    @b1 = create_category(:name => "B1", :category_type => @b_type, :parent => @b)
    @b2 = create_category(:name => "B2", :category_type => @b_type, :parent => @b)
    
    @a.parent.should be_blank
    @a.children.should == [@a1, @a2]
    
    @a1.parent.should == @a
    @a1.children.should == [@a1a]
    
    @a2.parent.should == @a
    @a2.children.should be_blank
    
    @a.ancestors.should be_blank
    @a1.ancestors.should == [@a]
    @a1a.ancestors.should == [@a, @a1]
    
    @a.path.should == "#{@a.name}"
    @a1.path.should == "#{@a.name} > #{@a1.name}"
    @a1a.path.should == "#{@a.name} > #{@a1.name} > #{@a1a.name}"
    
    Category.of_type("A").all.map(&:path).should == [
      "#{@a.name}",
      "#{@a.name} > #{@a1.name}",
      "#{@a.name} > #{@a1.name} > #{@a1a.name}",
      "#{@a.name} > #{@a2.name}"      
    ]
  end
  
end
