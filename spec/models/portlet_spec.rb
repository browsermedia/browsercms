require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Portlet do
  it "should create a new instance given valid attributes" do
    Portlet.create!(new_dynamic_portlet.attributes)
  end

  it "should be able to save attributes" do
    portlet = create_dynamic_portlet(:foo => "FOO")
    Portlet.first(:order => "created_at desc").foo.should == "FOO"
  end

  it "should be marked as not supporting revisioning" do
    p = new_dynamic_portlet
    p.class.should_not be_versioned
  end

  describe "when appearing in a list" do
    before(:each) do
      @p = new_dynamic_portlet
    end
    it "should pass correct portlet type name" do
      @p.portlet_type_name.should == "Dynamic Portlet"
    end
  end

end
