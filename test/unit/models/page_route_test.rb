require File.join(File.dirname(__FILE__), '/../../test_helper')

class PageRouteTest < ActiveSupport::TestCase
  
  def test_create
    page = Factory(:page, :path => "/things/overview")
    route = page.page_routes.build(:pattern => "/things/:year/:month/:day")
    route.add_requirement(:year, "\\d{4,}")
    route.add_requirement(:month, "\\d{2,}")
    route.add_requirement(:day, "\\d{2,}")
    route.add_condition(:method, "get")
    
    assert route.save
    assert_equal "/things/:year/:month/:day", route.pattern
    assert_equal({ 
      :controller => "cms/content", 
      :action => "show_page_route",
      :_page_route_id => route.id.to_s,
      :requirements => {
        :year => /\d{4,}/,
        :month => /\d{2,}/,
        :day => /\d{2,}/
      }, :conditions => {
        :method => :get
      }
    }, route.options_map)
  end
  
end
