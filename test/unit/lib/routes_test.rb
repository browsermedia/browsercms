require File.join(File.dirname(__FILE__), '/../../test_helper')

class RouteBuilder
  include Cms::Routes
end

class Bear < ActiveRecord::Base
  acts_as_content_block
end

class Kindness < ActiveRecord::Base
  acts_as_content_block
end

class RoutesTest < ActiveSupport::TestCase

  test "Verify behavior of classify, and how it works with already pluralized symbols" do
    assert_equal "Kindness", :kindnesses.to_s.classify, "routes will pass 'plural' symbols to 'content_block', rather than single"    
  end


  test "behavior of 'content_blocks' route generator" do
    rb = RouteBuilder.new

    # Expect
    rb.expects(:resources).with(:bears, {:member => {:publish => :put, :usages => :get, :versions => :get}})
    rb.expects(:version_cms_bears).with("/cms/bears/:id/version/:version", :controller => "cms/bears", :action => "version", :conditions => {:method => :get})
    rb.expects(:revert_to_cms_bears).with(
            "/cms/bears/:id/revert_to/:version",
            :controller => "cms/bears",
            :action => "revert_to",
            :conditions => {:method => :put})

    rb.content_blocks :bears

    # Verifies the exact messages being passed to the route generator
  end

  test "model names with s at the end behave identically (since content_blocks expects plural symbols)" do
    rb = RouteBuilder.new

    # Expect
    rb.expects(:resources).with(:kindnesses, {:member => {:publish => :put, :usages => :get, :versions => :get}})
    rb.expects(:version_cms_kindnesses).with("/cms/kindnesses/:id/version/:version", :controller => "cms/kindnesses", :action => "version", :conditions => {:method => :get})
    rb.expects(:revert_to_cms_kindnesses).with(
            "/cms/kindnesses/:id/revert_to/:version",
            :controller => "cms/kindnesses",
            :action => "revert_to",
            :conditions => {:method => :put})

    rb.content_blocks :kindnesses

    # Verifies the exact messages being passed to the route generator
  end
  

end
