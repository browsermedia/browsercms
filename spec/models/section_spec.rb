require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Section do
  
  it "should be able to create the root section" do
    create_section(:name => "My Site")
  end
  
  it "should be able to create sub-sections" do
    root = Section.create!(:name => "My Site")
    sub = create_section(:name => "Sub Section", :parent => root)
    root.children.first.should == sub
    sub.parent.should == root
  end
  
  it "should be able to be moved into another section if it is not the root" do
    root = create_section
    foo = create_section(:name => "Foo", :parent => root)
    bar = create_section(:name => "Bar", :parent => root)
    foo.parent.should == root
    foo.move_to_section(bar).should_not be_false
    foo.parent.should == bar
  end
  
  it "should not be able to be moved into another section if it is the root" do
    root = create_section
    foo = create_section(:name => "Foo", :parent => root)
    root.move_to_section(foo).should be_false
  end
  
  it "should be able to get the whole tree" do
    @root = create_section
    @users = create_section(:name => "Users", :parent => @root)
    @apps = create_section(:name => "Applications", :parent => @root)
    @library = create_section(:name => "Library", :parent => @root)

    @pbarry = create_section(:name => "pbarry", :parent => @users)
    
    @ff = create_section(:name => "FireFox.app", :parent => @apps)
    @textmate = create_section(:name => "TextMate.app", :parent => @apps)    
    
    Section.root.full_set.map{|s| {:name => s.name, :depth => s.level}}.should == [
      {:name => "My Site", :depth => 0},
      {:name => "Users", :depth => 1},
      {:name => "pbarry", :depth => 2},
      {:name => "Applications", :depth => 1},
      {:name => "FireFox.app", :depth => 2},
      {:name => "TextMate.app", :depth => 2},
      {:name => "Library", :depth => 1},      
    ]
    
  end
  
end
