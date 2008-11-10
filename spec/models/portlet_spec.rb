require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Portlet do
  it "should create a new instance given valid attributes" do
    Portlet.create!(new_portlet.attributes)
  end

  it "should be able to save attributes" do
    portlet = create_portlet(:foo => "FOO")
    Portlet.first(:order => "created_at desc").foo.should == "FOO"
  end

  it "should be able to be rendered" do
    portlet_type = create_portlet_type(:code => '@foo = "FOO"', :template => "<h1><%= @foo %></h1>")
    portlet = create_portlet(:portlet_type => portlet_type)
    portlet.render.should == "<h1>FOO</h1>"
  end

  it "should be marked as not supporting revisioning" do
    p = Portlet.new
    p.versionable?.should be_false
  end

  describe "when appearing in a list" do
    before(:each) do
      @portlet_type = create_portlet_type(:name => "Recent Stuff")
      @p = Portlet.new(:portlet_type => @portlet_type)
    end
    it "should pass correct portlet type name" do
      @p.portlet_type_name.should == "Recent Stuff"
    end
  end
  describe "when specifying custom CRUD actions for Portlets" do
    before(:each) do
      @content_type = ContentType.new(:name => "Portlet")
    end
    it "should have custom view for new" do
      @content_type.template_for_new.should == "cms/portlets/select_portlet_type"
    end

    it "should have portlet_type_name" do
      @content_type.columns_for_index.should == [{:label => "Portlet Type", :method => "portlet_type_name"}]
    end
  end

end
