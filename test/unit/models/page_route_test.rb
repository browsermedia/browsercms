require 'test_helper'

class PageRouteTest < ActiveSupport::TestCase
  def setup
    @route = PageRoute.new(:pattern=>"/:some/:pattern", :name=>"My Name")
  end


  def test_create
    page = Factory(:page, :path => "/things/overview")
    route = page.page_routes.build(:pattern => "/things/:year/:month/:day")
    route.add_requirement(:year, "\\d{4,}")
    route.add_requirement(:month, "\\d{2,}")
    route.add_requirement(:day, "\\d{2,}")
    route.add_condition(:method, "get")

    assert route.save!
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

  # Rails 3 Routing
  test "match :to" do
    assert_equal "cms/content#show_page_route", @route.to
  end

  test "match :as" do
    assert_equal "my_name", @route.route_name
    assert_equal "my_name", @route.as
  end

  test "default method conditions" do
    assert_equal [:get, :post], @route.via
  end
  test "setting method conditions" do
    @route.add_condition(:method, "post")
    assert_equal([:post], @route.via)

  end

  test "constraints allows for regular expressions to be set for pattern elements in a route" do
    @route.add_requirement(:year, '\d{4,}')
    assert_equal({:year => /\d{4,}/}, @route.constraints)
  end

  test "add_constraint is replacement method for add_requirement " do
    @route.add_requirement(:year, '\d{4,}')
    assert_equal({:year => /\d{4,}/}, @route.constraints)
  end

  test "constraints handles more than one pattern" do
    @route.add_requirement(:month, '\d{2,}')
    @route.add_requirement(:day, '\d{2,}')
    @route.add_requirement(:year, '\d{4,}')
    assert_equal({:month => /\d{2,}/, :day => /\d{2,}/, :year => /\d{4,}/}, @route.constraints)
  end
end


class LoadingPageRoutesTest < ActiveSupport::TestCase

  def setup

  end

  test "can_be_loaded?" do
    PageRoute.expects(:database_exists?).returns(true)
    PageRoute.expects(:table_exists?).returns(true)

    assert_equal true, PageRoute.can_be_loaded?
  end

  test "Routes cannot be loaded if the table doesn't exist" do
    PageRoute.expects(:database_exists?).returns(true)
    PageRoute.expects(:table_exists?).returns(false)

    assert_equal false, PageRoute.can_be_loaded?
  end

  test "Routes cannot be loaded if the database doesn't exist" do
    PageRoute.expects(:database_exists?).returns(false)

    assert_equal false, PageRoute.can_be_loaded?
  end
end