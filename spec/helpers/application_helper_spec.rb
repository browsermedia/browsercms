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
  describe "determine_order" do
    describe "when the current order and the order match" do
      describe "and the current order has ' desc' in it" do
        describe "and the order has ' desc' in it" do
          it "should return the order without desc" do
            current_order = "foo desc"
            order = "foo desc"
            helper.determine_order(current_order, order).should == "foo"
          end
        end 
        describe "and the order does not have ' desc' in it" do
          it "should return the order with ' desc' appended" do
            current_order = "foo desc"
            order = "foo"
            helper.determine_order(current_order, order).should == "foo"          
          end
        end
      end
      describe "and the current order does not have ' desc' in it" do
        describe "and the order has ' desc' in it" do
          it "should return the order with desc" do
            current_order = "foo"
            order = "foo desc"
            helper.determine_order(current_order, order).should == "foo desc"
          end
        end 
        describe "and the order does not have ' desc' in it" do
          it "should return the order with ' desc' appended" do
            current_order = "foo"
            order = "foo"
            helper.determine_order(current_order, order).should == "foo desc"
          end
        end
      end
    end
    describe "when the current order and the order do not match" do
      describe "and the order has ' desc' in it" do
        it "should return the order with ' desc'" do
          current_order = "foo"
          order = "bar desc"
          helper.determine_order(current_order, order).should == "bar desc"          
        end
      end
      describe "and the order has ' desc' in it" do
        it "should return the order with ' desc'" do
          current_order = "foo"
          order = "bar"
          helper.determine_order(current_order, order).should == "bar"
        end
      end
    end
  end
end