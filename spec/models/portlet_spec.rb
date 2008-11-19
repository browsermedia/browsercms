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
    p.versionable?.should be_false
  end

  describe "when appearing in a list" do
    before(:each) do
      @p = new_dynamic_portlet
    end
    it "should pass correct portlet type name" do
      @p.portlet_type_name.should == "Dynamic Portlet"
    end
  end
  describe "when specifying custom CRUD actions for Portlets" do
    before(:each) do
      @content_type = ContentType.new(:name => "Portlet")
    end

    it "should have portlet_type_name" do
      @content_type.columns_for_index.should == [{:label => "Type", :method => "portlet_type_name"}]
    end
  end

end
