require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Redirect do
  
  it "should allow redirect from a path to an external url" do
    new_redirect(:from_path => "/test", :to_path => "http://browsermedia.com").should be_valid    
  end
  
  it "should allow redirect from a path to an internal path" do
    new_redirect(:from_path => "/test", :to_path => "/example").should be_valid    
  end
  
  it "should require a from path" do
    new_redirect(:from_path => " ", :to_path => "http://browsermedia.com").should_not be_valid    
  end
  
  it "should require a to path" do
    new_redirect(:from_path => "/test", :to_path => " ").should_not be_valid    
  end
  
  it "should not allow duplicate " do
    create_redirect(:from_path => "/test", :to_path => "/example")
    new_redirect(:from_path => "/test", :to_path => "/example").should_not be_valid    
  end
  
end