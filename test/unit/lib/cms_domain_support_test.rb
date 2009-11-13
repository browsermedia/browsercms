require File.join(File.dirname(__FILE__), '/../../test_helper')
require 'mocha'

class CmsDomainSupportTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  test "cms_site? determines if the first subdomain is 'cms'" do
    c = Cms::ApplicationController.new
    request = mock

    c.expects(:request).returns(request)
    request.expects(:subdomains).returns(["cms"])

    assert c.send :cms_site?
  end

   test "A url that isn't a cms domain" do
    c = Cms::ApplicationController.new
    request = mock

    c.expects(:request).returns(request)
    request.expects(:subdomains).returns(["www"])

    assert_equal false, c.send(:cms_site?)
   end

  test "default cms domain" do
    c = Cms::ApplicationController.new

    assert_equal "cms", c.send(:cms_domain_prefix)
  end

  test "prepare_for_rendererable" do
        
  end
end