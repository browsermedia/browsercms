require File.dirname(__FILE__) + '/../spec_helper'

#
# This seems slightly silly to be testing our fixtures, but considering there are potentially wiring/validation errors when
# creating complex objects its probably better to have them fail fast here rather than all over the test suite.
#
describe "Fixture Replacements" do

  describe "portlets" do
    before(:each) do
      @portlet = create_portlet
      @portlet.reload
    end
    it "should create a valid portlet" do
      @portlet.should_not be_nil
    end
    it "should have valid type" do
      @portlet.portlet_type.should_not be_nil
    end
  end
end