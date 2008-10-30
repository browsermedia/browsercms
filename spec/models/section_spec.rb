require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Section do
  
  it "should be able to create the root section" do
    create_section(:name => "My Site")
  end
  
  it "should not allow '/' characters in the name" do
    @section = new_section(:name => "OMG / WTF / BBQ")
    @section.should_not be_valid
    @section.errors.full_messages.should == ["Name cannot contain '/'"]
  end
  
  it "should be able to create sub-sections" do
    sub = create_section(:name => "Sub Section", :parent => root_section)
    root_section.sections.first(:order => "created_at desc").should == sub
    sub.parent.should == root_section
  end

  # Not true, you can have more than one root section because of domains 
  # it "should only be allowed to create 1 root section" do
  #   create_section(:name => "foo")
  #   section = new_section(:name => "bar")
  #   section.should_not be_valid
  #   section.errors.on(:parent_id).should == "section is required"
  # end
  
  it "should be able to be moved into another section if it is not the root" do
    foo = create_section(:name => "Foo", :parent => root_section)
    bar = create_section(:name => "Bar", :parent => root_section)
    foo.parent.should == root_section
    foo.move_to(bar).should be_true
    foo.parent.should == bar
  end
  
  it "should not be able to be moved into another section if it is the root" do
    foo = create_section(:name => "Foo", :parent => root_section)
    root_section.move_to(foo).should be_false
  end  
  
  it "should be able to find the first page in a section" do
    @a = create_section(:parent => root_section, :name => "A")
    @a1 = create_section(:parent => @a, :name => "A1")
    @a1a = create_section(:parent => @a1, :name => "A1a")
    @foo = create_page(:section => @a1a, :name => "Foo")
    @b = create_section(:parent => root_section, :name => "B")
    root_section.first_page.should == @foo
    @a.first_page.should == @foo
    @a1.first_page.should == @foo
    @a1a.first_page.should == @foo
    @b.first_page.should be_nil
  end
  
  describe "#find_by_name_path" do
    before do
      @a = create_section(:parent => root_section, :name => "A")
      @b = create_section(:parent => @a, :name => "B")
      @c = create_section(:parent => @b, :name => "C")
    end
    it "should find the root section" do
      Section.find_by_name_path("/").should == root_section
    end
    it "should find a section 1 level deep" do
      Section.find_by_name_path("/A/").should == @a
    end
    it "should find a section 2 level deep" do
      Section.find_by_name_path("/A/B/").should == @b
    end
    it "should find a section 3 level deep" do
      Section.find_by_name_path("/A/B/C/").should == @c
    end
  end
  
  
end

describe "A section with a section in it" do
  
  before do
    @section = create_section(:parent => root_section)
    create_section(:parent => @section)
  end
  
  it "should not be empty" do
    @section.should_not be_empty
  end  
  
  it "should not be deletable" do
    @section.should_not be_deletable    
  end
  
  describe ", when you try to destroy it, " do
    before { @destroying_it = lambda { @section.destroy } }
    it "should return false" do
      @destroying_it.call.should be_false
    end
    it "should not change the number of sections" do
      @destroying_it.should_not change(Section, :count)
    end
  end
    
end

describe "A section with a page in it" do
  
  before do
    @section = create_section(:parent => root_section)
    create_page(:section => @section)
  end
  
  it "should not be empty" do
    @section.should_not be_empty
  end
  
  it "should not be deletable" do
    @section.should_not be_deletable    
  end
  
  describe ", when you try to destroy it, " do
    before { @destroying_it = lambda { @section.destroy } }
    it "should return false" do
      @destroying_it.call.should be_false
    end
    it "should not change the number of sections" do
      @destroying_it.should_not change(Section, :count)
    end
  end
    
end

describe "The root section" do
    
  before do
    @section = root_section
  end  
    
  it "should be empty" do
    @section.should be_empty
  end
    
  it "should not be deletable" do
    @section.should_not be_deletable    
  end
  
  describe ", when you try to destroy it, " do
    before { @destroying_it = lambda { @section.destroy } }
    it "should return false" do
      @destroying_it.call.should be_false
    end
    it "should not change the number of sections" do
      @destroying_it.should_not change(Section, :count)
    end
  end
    
end

describe "An empty section" do
    
  before do
    @section = create_section(:parent => root_section)
  end    
    
  it "should be deletable" do
    @section.should be_deletable    
  end
  
  it "should be empty" do
    @section.should be_empty
  end
  
  describe ", when you try to destroy it, " do
    before { @destroying_it = lambda { @section.destroy } }
    it "should not return false" do
      @destroying_it.call.should_not be_false
    end
    it "should decrease the number of sections by 1" do
      @destroying_it.should change(Section, :count).by(-1)
    end
  end
    
end

