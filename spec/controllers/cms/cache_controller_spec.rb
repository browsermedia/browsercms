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
      controller.cache_store.should be_exist(@page.path)
      post :expire
      controller.cache_store.should_not be_exist(@page.path)
    end
  end
end