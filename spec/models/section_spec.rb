require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Section do
  
  it "should be able to create the root section" do
    create_section(:name => "My Site")
  end
  
  it "should be able to create sub-sections" do
    root = create_section(:name => "My Site")
    sub = create_section(:name => "Sub Section", :parent => root)
    root.children.first(:order => "created_at desc").should == sub
    sub.parent.should == root
  end
  
  it "should only be allowed to create 1 root section" do
    create_section(:name => "foo")
    section = new_section(:name => "bar")
    section.should_not be_valid
    section.errors.on(:parent_id).should == "Parent section is required"
  end
  
  it "should be able to be moved into another section if it is not the root" do
    root = create_section
    foo = create_section(:name => "Foo", :parent => root)
    bar = create_section(:name => "Bar", :parent => root)
    foo.parent.should == root
    foo.move_to(bar).should be_true
    foo.parent.should == bar
  end
  
  it "should not be able to be moved into another section if it is the root" do
    root = create_section
    foo = create_section(:name => "Foo", :parent => root)
    root.move_to(foo).should be_false
  end
  
end
