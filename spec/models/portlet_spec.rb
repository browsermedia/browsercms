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
    p.supports_versioning?.should be_false
  end
end
