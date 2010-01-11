require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::MenuHelperTest < ActionView::TestCase

  def test_menu_items
    Page.first.update_attributes(:hidden => true, :publish_on_save => true)
    create_nfl_data

    expected = [
            { :id => "section_#{@afc.id}", :url => "/buf", :name => "AFC", :children => [
                    { :id => "section_#{@afc_east.id}", :url => "/buf", :name => "East" },
                    { :id => "section_#{@afc_north.id}", :url => "/bal", :name => "North", :children => [
                            { :id => "page_#{@bal.id}", :selected => true, :url => "/bal", :name => "Baltimore Ravens" },
                            { :id => "page_#{@cin.id}", :url => "/cin", :name => "Cincinnati Bengals" },
                            { :id => "page_#{@cle.id}", :url => "/cle", :name => "Cleveland Browns" },
                            { :id => "page_#{@pit.id}", :url => "/pit", :name => "Pittsburgh Steelers" }
                    ] },
                    { :id => "section_#{@afc_south.id}", :url => "/hou", :name => "South" },
                    { :id => "section_#{@afc_west.id}", :url => "/den", :name => "West" }
            ] },
            { :id => "section_#{@nfc.id}", :url => "/dal", :name => "NFC" },
            { :id => "section_#{@int.id}", :url => "/international", :name => "International" }
    ]

    assert_equal expected, menu_items(:page => @bal)

    @page = @bal
    assert_equal expected, menu_items

    expected = [
            { :id => "section_#{@afc.id}", :url => "/buf", :name => "AFC", :children => [
                    { :id => "section_#{@afc_east.id}", :url => "/buf", :name => "East" },
                    { :id => "section_#{@afc_north.id}", :url => "/bal", :name => "North" },
                    { :id => "section_#{@afc_south.id}", :url => "/hou", :name => "South" },
                    { :id => "section_#{@afc_west.id}", :url => "/den", :name => "West" }
            ] },
            { :id => "section_#{@nfc.id}", :url => "/dal", :name => "NFC" },
            { :id => "section_#{@int.id}", :url => "/international", :name => "International" }
    ]

    assert_equal expected, menu_items(:depth => 2)

    expected = [
            { :id => "section_#{@afc_east.id}", :url => "/buf", :name => "East" },
            { :id => "section_#{@afc_north.id}", :url => "/bal", :name => "North", :children => [
                    { :id => "page_#{@bal.id}", :selected => true, :url => "/bal", :name => "Baltimore Ravens" },
                    { :id => "page_#{@cin.id}", :url => "/cin", :name => "Cincinnati Bengals" },
                    { :id => "page_#{@cle.id}", :url => "/cle", :name => "Cleveland Browns" },
                    { :id => "page_#{@pit.id}", :url => "/pit", :name => "Pittsburgh Steelers" }
            ] },
            { :id => "section_#{@afc_south.id}", :url => "/hou", :name => "South" },
            { :id => "section_#{@afc_west.id}", :url => "/den", :name => "West" }
    ]

    assert_equal expected, menu_items(:from_top => 1, :depth => 2)

    expected = [
            { :id => "section_#{@afc.id}", :url => "/buf", :name => "AFC", :children => [
                    { :id => "section_#{@afc_east.id}", :url => "/buf", :name => "East" },
                    { :id => "section_#{@afc_north.id}", :url => "/bal", :name => "North" },
                    { :id => "section_#{@afc_south.id}", :url => "/hou", :name => "South" },
                    { :id => "section_#{@afc_west.id}", :url => "/den", :name => "West" }
            ] },
            { :id => "section_#{@nfc.id}", :url => "/dal", :name => "NFC", :children => [
                    { :id => "section_#{@nfc_east.id}", :url => "/dal", :name => "East" },
                    { :id => "section_#{@nfc_north.id}", :url => "/chi", :name => "North" },
                    { :id => "section_#{@nfc_south.id}", :url => "/atl", :name => "South" },
                    { :id => "section_#{@nfc_west.id}", :url => "/ari", :name => "West" }
            ] },
            { :id => "section_#{@int.id}", :url => "/international", :name => "International" }
    ]

    assert_equal expected, menu_items(:depth => 2, :show_all_siblings => true)

    expected = [
            { :id => "section_#{@afc.id}", :url => "/buf", :name => "AFC" },
            { :id => "section_#{@nfc.id}", :url => "/dal", :name => "NFC" },
            { :id => "section_#{@int.id}", :url => "/international", :name => "International" }
    ]

    assert_equal expected, menu_items(:depth => 1)

    expected = [
            { :id => "section_#{@afc_east.id}", :url => "/buf", :name => "East" },
            { :id => "section_#{@afc_north.id}", :url => "/bal", :name => "North" },
            { :id => "section_#{@afc_south.id}", :url => "/hou", :name => "South" },
            { :id => "section_#{@afc_west.id}", :url => "/den", :name => "West" }
    ]

    assert_equal expected, menu_items(:from_top => 1, :depth => 1)

    expected = [
            { :id => "section_#{@afc_east.id}", :url => "/buf", :name => "East" },
            { :id => "section_#{@afc_north.id}", :url => "/bal", :name => "North" },
            { :id => "section_#{@afc_south.id}", :url => "/hou", :name => "South" }
    ]

    assert_equal expected, menu_items(:from_top => 1, :depth => 1, :limit => 3)

    expected = [
            { :id => "section_#{@afc.id}", :url => "/buf", :name => "AFC" },
            { :id => "section_#{@nfc.id}", :url => "/dal", :name => "NFC" },
            { :id => "section_#{@int.id}", :selected => true, :url => "/international", :name => "International" }
    ]

    assert_equal expected, menu_items(:page => @overview)
    
  end

  def test_menu_with_links
    Page.first.update_attributes(:hidden => true, :publish_on_save => true)

    @news = Factory(:section, :parent => root_section, :name => "News", :path => "/whatever")
    @press_releases = Factory(:page, :section => @news, :name => "Press Releases", :path => "/press_releases", :publish_on_save => true)
    @corporate_news = Factory(:link, :section => @news, :name => "Corporate News", :url => "/news", :new_window => false, :publish_on_save => true)
    @cnn = Factory(:link, :section => @news, :name => "CNN", :url => "http://www.cnn.com", :new_window => true, :publish_on_save => true)

    expected = [
            { :id => "section_#{@news.id}", :url => "/press_releases", :name => "News", :children => [
                    { :id => "page_#{@press_releases.id}", :selected => true, :url => "/press_releases", :name => "Press Releases" },
                    { :id => "link_#{@corporate_news.id}", :url => "/news", :name => "Corporate News" },
                    { :id => "link_#{@cnn.id}", :url => "http://www.cnn.com", :target => "_blank", :name => "CNN" }
            ] }
    ]

    @page = @press_releases
    assert_equal expected, menu_items
    assert_equal [], menu_items(:from_top => 42)
  end

  def test_render_menu_does_not_show_unpublished_pages
    @section = Factory(:section, :name => "Test", :path => "/test")
    @page = Factory(:page, :section => @section, :name => "Overview", :path => "/test", :publish_on_save => true)

    @draft_page = Factory(:page, :section => @section, :name => "Draft v1", :path => "/draft", :publish_on_save => true)
    @draft_page.update_attributes(:name => "Draft v2")
    @never_published = Factory(:page, :section => @section, :name => "Never Published", :path => "/never_published")

    expected = [
            { :id => "page_#{@page.id}", :name => "Overview", :url => "/test", :selected => true },
            { :id => "page_#{@draft_page.id}", :name => "Draft v1", :url => "/draft" }
    ]

    assert_equal expected, menu_items(:from_top => 1)
  end

  def test_render_menu_with_path
    @test = Factory(:page, :section => root_section, :name => "Test", :path => "/test", :publish_on_save => true)
    @footer = Factory(:section, :parent => root_section, :name => "Footer", :path => "/footer")
    @about_us = Factory(:page, :section => @footer, :name => "About Us", :path => "/about_us", :publish_on_save => true)
    @contact_us = Factory(:page, :section => @footer, :name => "Contact Us", :path => "/contact_us", :publish_on_save => true)
    @privacy_policy = Factory(:page, :section => @footer, :name => "Privacy Policy", :path => "/privacy_policy", :publish_on_save => true)

    expected = [
            { :id => "page_#{@about_us.id}", :url => "/about_us", :name => "About Us" },
            { :id => "page_#{@contact_us.id}", :url => "/contact_us", :name => "Contact Us" },
            { :id => "page_#{@privacy_policy.id}", :url => "/privacy_policy", :name => "Privacy Policy" }
    ]

    actual = menu_items(:page => @test, :path => "/footer", :from_top => 1)
    assert_equal expected, actual

    expected = [
            { :id => "page_#{@about_us.id}", :url => "/about_us", :name => "About Us" },
            { :id => "page_#{@contact_us.id}", :url => "/contact_us", :name => "Contact Us", :selected => true },
            { :id => "page_#{@privacy_policy.id}", :url => "/privacy_policy", :name => "Privacy Policy" }
    ]

    actual = menu_items(:page => @contact_us, :path => "/footer", :from_top => 1)
    assert_equal expected, actual
  end

  test "nil current page should return empty string" do
    @page = nil
    self.expects(:render).never

    assert_equal "", render_menu
  end

  protected
  def create_nfl_data
    @afc = Factory(:section, :parent => root_section, :name => "AFC")

    @afc_east = Factory(:section, :parent => @afc, :name => "East")
    @buf = Factory(:page, :section => @afc_east, :name => "Buffalo Bills", :path => "/buf", :publish_on_save => true)
    @mia = Factory(:page, :section => @afc_east, :name => "Miami Dolphins", :path => "/mia", :publish_on_save => true)
    @ne = Factory(:page, :section => @afc_east, :name => "New England Patriots", :path => "/ne", :publish_on_save => true)
    @nyj = Factory(:page, :section => @afc_east, :name => "New York Jets", :path => "/nyj", :publish_on_save => true)

    @afc_north = Factory(:section, :parent => @afc, :name => "North")
    @bal = Factory(:page, :section => @afc_north, :name => "Baltimore Ravens", :path => "/bal", :publish_on_save => true)
    @cin = Factory(:page, :section => @afc_north, :name => "Cincinnati Bengals", :path => "/cin", :publish_on_save => true)
    @cle = Factory(:page, :section => @afc_north, :name => "Cleveland Browns", :path => "/cle", :publish_on_save => true)
    @pit = Factory(:page, :section => @afc_north, :name => "Pittsburgh Steelers", :path => "/pit", :publish_on_save => true)

    @afc_south = Factory(:section, :parent => @afc, :name => "South")
    @hou = Factory(:page, :section => @afc_south, :name => "Houston Texans", :path => "/hou", :publish_on_save => true)
    @ind = Factory(:page, :section => @afc_south, :name => "Indianapolis Colts", :path => "/ind", :publish_on_save => true)
    @jac = Factory(:page, :section => @afc_south, :name => "Jacksonville Jaguars", :path => "/jac", :publish_on_save => true)
    @ten = Factory(:page, :section => @afc_south, :name => "Tennessee Titans", :path => "/ten", :publish_on_save => true)

    @afc_west = Factory(:section, :parent => @afc, :name => "West")
    @den = Factory(:page, :section => @afc_west, :name => "Denver Broncos", :path => "/den", :publish_on_save => true)
    @kc = Factory(:page, :section => @afc_west, :name => "Kansas City Chiefs", :path => "/kc", :publish_on_save => true)
    @oak = Factory(:page, :section => @afc_west, :name => "Oakland Raiders", :path => "/oak", :publish_on_save => true)
    @sd = Factory(:page, :section => @afc_west, :name => "San Diego Chargers", :path => "/sd", :publish_on_save => true)

    @nfc = Factory(:section, :parent => root_section, :name => "NFC")

    @nfc_east = Factory(:section, :parent => @nfc, :name => "East")
    @dal = Factory(:page, :section => @nfc_east, :name => "Dallas Cowboys", :path => "/dal", :publish_on_save => true)
    @nyg = Factory(:page, :section => @nfc_east, :name => "New York Giants", :path => "/nyg", :publish_on_save => true)
    @phi = Factory(:page, :section => @nfc_east, :name => "Philadelphia Eagles", :path => "/phi", :publish_on_save => true)
    @was = Factory(:page, :section => @nfc_east, :name => "Washington Redskins", :path => "/was", :publish_on_save => true)

    @nfc_north = Factory(:section, :parent => @nfc, :name => "North")
    @chi = Factory(:page, :section => @nfc_north, :name => "Chicago Bears", :path => "/chi", :publish_on_save => true)
    @det = Factory(:page, :section => @nfc_north, :name => "Detroit Lions", :path => "/det", :publish_on_save => true)
    @gb = Factory(:page, :section => @nfc_north, :name => "Green Bay Packers", :path => "/gb", :publish_on_save => true)
    @min = Factory(:page, :section => @nfc_north, :name => "Minnesota Vikings", :path => "/min", :publish_on_save => true)

    @nfc_south = Factory(:section, :parent => @nfc, :name => "South")
    @atl = Factory(:page, :section => @nfc_south, :name => "Atlanta Falcons", :path => "/atl", :publish_on_save => true)
    @car = Factory(:page, :section => @nfc_south, :name => "Carolina Pathers", :path => "/car", :publish_on_save => true)
    @no = Factory(:page, :section => @nfc_south, :name => "New Orleans Saints", :path => "/no", :publish_on_save => true)
    @tb = Factory(:page, :section => @nfc_south, :name => "Tampa Bay Buccaneers", :path => "/tb", :publish_on_save => true)

    @nfc_west = Factory(:section, :parent => @nfc, :name => "West")
    @ari = Factory(:page, :section => @nfc_west, :name => "Arizona Cardinals", :path => "/ari", :publish_on_save => true)
    @sf = Factory(:page, :section => @nfc_west, :name => "San Francisco 49ers", :path => "/sf", :publish_on_save => true)
    @sea = Factory(:page, :section => @nfc_west, :name => "Seattle Seahawks", :path => "/sea", :publish_on_save => true)
    @stl = Factory(:page, :section => @nfc_west, :name => "St. Louis Rams", :path => "/stl", :publish_on_save => true)

    @int = Factory(:section, :parent => root_section, :name => "International", :path => '/international')
    @overview = Factory(:page, :section => @int, :name => "Overview", :path => "/international", :publish_on_save => true, :hidden => true)
  end


end
