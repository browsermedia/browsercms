require "test_helper"

module Cms
  class DomainSupportTest < ActiveSupport::TestCase

    include DomainSupport

    def setup
      given_rails_page_caching_is(true)
    end

    test "(i.e. production defaults overriden) Use a single domain" do
      given_use_single_domain_is(true)
      refute using_cms_subdomains?
    end

    test "(i.e. default production) If page caching is enabled, then we use subdomains." do
      given_use_single_domain_is(false)
      assert using_cms_subdomains?
    end

    test "(i.e. default development/testing mode) Use a single domain" do
      given_use_single_domain_is(false)
      given_rails_page_caching_is(false)
      refute using_cms_subdomains?
    end

    test "should not cache page if we are using a single domain" do
      given_rails_page_caching_is true
      given_use_single_domain_is true

      refute using_cms_subdomains?
    end

    test "with subdomains and caching" do
      given_rails_page_caching_is true
      given_use_single_domain_is false

      assert using_cms_subdomains?
    end

    test "no caching, single domain" do
      given_rails_page_caching_is false
      given_use_single_domain_is true

      refute using_cms_subdomains?
    end

    private

    def given_rails_page_caching_is(value)
      stubs(:perform_caching).returns(value)
    end

    def given_use_single_domain_is(value)
      Rails.configuration.cms.expects(:use_single_domain).returns(value).at_least_once
    end
  end
end