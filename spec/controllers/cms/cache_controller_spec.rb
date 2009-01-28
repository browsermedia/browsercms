require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::CacheController do
  integrate_views
  include Cms::PathHelper
  
  before { login_as_user }
  
  describe "expiring the cache" do
    before do
      @page = create_page
      controller.cache_store.write(@page.path, 'Test')
    end
    it "should remove a cached page" do  
      pending "implementation of Caching"
    end
  end
end