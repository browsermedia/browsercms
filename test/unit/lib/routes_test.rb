require_relative '../../test_helper'

class RouteBuilder
  include Cms::Routes
end

class Bear < ActiveRecord::Base
  acts_as_content_block
end

class Kindness < ActiveRecord::Base
  acts_as_content_block
end

# This verifiest the behavior of how BrowserCMS creates new routes
# for projects.
class RoutesTest < ActiveSupport::TestCase

  test "Verify behavior of classify, and how it works with already pluralized symbols" do
    assert_equal "Kindness", :kindnesses.to_s.classify, "routes will pass 'plural' symbols to 'content_block', rather than single"    
  end


  # These tests could be better, but I'm not entirely sure how to mock test syntax that looks like:
  #
  # resources content_block_name do
  #   member do
  #     put :publish if content_block.publishable?
  #     get :versions if content_block.versioned?
  #     get :usages if content_block.connectable?
  #   end
  # end
  #
  # Which is what 'content_blocks' is currently doing.
  test "behavior of 'content_blocks' route generator" do
    rb = RouteBuilder.new

    # Expect
    rb.expects(:resources).with(:bears)
    rb.expects(:get).with('/bears/:id/version/:version', {:to => 'cms/bears#version', :as => :version_cms_bears})
    rb.expects(:put)
    rb.content_blocks :bears

    # Verifies the exact messages being passed to the route generator
  end

  # Could be better. See previous method.
  test "model names with s at the end behave identically (since content_blocks expects plural symbols)" do
    rb = RouteBuilder.new
    rb.expects(:resources).with(:kindnesses)
    rb.expects(:get).with('/kindnesses/:id/version/:version', {:to => 'cms/kindnesses#version', :as => :version_cms_kindnesses})
    rb.expects(:put)

    rb.content_blocks :kindnesses

    # Verifies the exact messages being passed to the route generator
  end
  

end
