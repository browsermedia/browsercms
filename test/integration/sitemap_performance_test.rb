require 'test_helper'

class SitemapPerformanceTest < ActionDispatch::IntegrationTest
  include Cms::IntegrationTestHelper

  def setup
    given_a_site_exists
  end

  def test_homepage
    r = Benchmark.measure do
      get '/'
    end
    assert r.real < 1, "Should complete in under 1 sec. Was #{r.real}"
  end

  test "sitemap" do
    # Make me work someday

    #login_as_cms_admin
    #
    #puts Benchmark.measure do
    #  get '/cms/sitemap'
    #end
  end
end