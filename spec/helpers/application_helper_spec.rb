require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::ApplicationHelper do
  describe "url_with_mode" do
    it "should set the mode if the url has no query string or path" do
      helper.url_with_mode("http://localhost:3000", "edit").should == "?mode=edit"
    end
    it "should set the mode if the url has no query string or path" do
      helper.url_with_mode("http://localhost:3000/", "edit").should == "/?mode=edit"
    end
    it "should set the mode if the url has no query string" do
      helper.url_with_mode("http://localhost:3000/foo", "edit").should == "/foo?mode=edit"
    end
    it "should set the mode if the url has a query string" do
      helper.url_with_mode("http://localhost:3000/foo?bar=1", "edit").should == "/foo?bar=1&mode=edit"
    end
    it "should set the mode if the url has a query string with a mode" do
      helper.url_with_mode("http://localhost:3000/foo?mode=view", "edit").should == "/foo?mode=edit"
    end
    it "should set the mode if the url has a query string with a mode and other params" do
      helper.url_with_mode("http://localhost:3000/foo?bar=1&mode=view", "edit").should == "/foo?bar=1&mode=edit"
    end
    it "should set the mode if the url has a query string with a mode and other params with mode in the name" do
      helper.url_with_mode("http://localhost:3000/foo?other_mode=1&mode=view", "edit").should == "/foo?other_mode=1&mode=edit"
    end
    it "should set the mode if the path has a query string with a mode and other params with mode in the name" do
      helper.url_with_mode("/foo?other_mode=1&mode=view", "edit").should == "/foo?other_mode=1&mode=edit"
    end    
  end  
end