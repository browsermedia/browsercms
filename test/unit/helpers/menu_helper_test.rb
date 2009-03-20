require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::MenuHelperTest < ActionView::TestCase
  
  def test_render_menu
    Page.first.update_attributes(:hidden => true, :publish_on_save => true)
    create_nfl_data

    expected = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc.id}" class="first open">
      <a href="/buf">AFC</a>
      <ul>
        <li id="section_#{@afc_east.id}" class="first">
          <a href="/buf">East</a>
        </li>
        <li id="section_#{@afc_north.id}" class="open">
          <a href="/bal">North</a>
          <ul>
            <li id="page_#{@bal.id}" class="first on">
              <a href="/bal">Baltimore Ravens</a>
            </li>
            <li id="page_#{@cin.id}">
              <a href="/cin">Cincinnati Bengals</a>
            </li>
            <li id="page_#{@cle.id}">
              <a href="/cle">Cleveland Browns</a>
            </li>
            <li id="page_#{@pit.id}" class="last">
              <a href="/pit">Pittsburgh Steelers</a>
            </li>
          </ul>
        </li>
        <li id="section_#{@afc_south.id}">
          <a href="/hou">South</a>
        </li>
        <li id="section_#{@afc_west.id}" class="last">
          <a href="/den">West</a>
        </li>
      </ul>
    </li>
    <li id="section_#{@nfc.id}" class="last">
      <a href="/dal">NFC</a>
    </li>
  </ul>
</div>
HTML

    @page = @bal
    assert_equal expected, render_menu
    assert_match /<div class=\"leftnav\">/, render_menu(:class => "leftnav")
    
    expected =  <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc.id}" class="first open">
      <a href="/buf">AFC</a>
      <ul>
        <li id="section_#{@afc_east.id}" class="first">
          <a href="/buf">East</a>
        </li>
        <li id="section_#{@afc_north.id}" class="open">
          <a href="/bal">North</a>
        </li>
        <li id="section_#{@afc_south.id}">
          <a href="/hou">South</a>
        </li>
        <li id="section_#{@afc_west.id}" class="last">
          <a href="/den">West</a>
        </li>
      </ul>
    </li>
    <li id="section_#{@nfc.id}" class="last">
      <a href="/dal">NFC</a>
    </li>
  </ul>
</div>
HTML
    
    assert_equal expected, render_menu(:depth => 2)
    
    expected = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc_east.id}" class="first">
      <a href="/buf">East</a>
    </li>
    <li id="section_#{@afc_north.id}" class="open">
      <a href="/bal">North</a>
      <ul>
        <li id="page_#{@bal.id}" class="first on">
          <a href="/bal">Baltimore Ravens</a>
        </li>
        <li id="page_#{@cin.id}">
          <a href="/cin">Cincinnati Bengals</a>
        </li>
        <li id="page_#{@cle.id}">
          <a href="/cle">Cleveland Browns</a>
        </li>
        <li id="page_#{@pit.id}" class="last">
          <a href="/pit">Pittsburgh Steelers</a>
        </li>
      </ul>
    </li>
    <li id="section_#{@afc_south.id}">
      <a href="/hou">South</a>
    </li>
    <li id="section_#{@afc_west.id}" class="last">
      <a href="/den">West</a>
    </li>
  </ul>
</div>
HTML
    
    assert_equal expected, render_menu(:from_top => 1, :depth => 2)
    
    expected = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc.id}" class="first open">
      <a href="/buf">AFC</a>
      <ul>
        <li id="section_#{@afc_east.id}" class="first">
          <a href="/buf">East</a>
        </li>
        <li id="section_#{@afc_north.id}" class="open">
          <a href="/bal">North</a>
        </li>
        <li id="section_#{@afc_south.id}">
          <a href="/hou">South</a>
        </li>
        <li id="section_#{@afc_west.id}" class="last">
          <a href="/den">West</a>
        </li>
      </ul>
    </li>
    <li id="section_#{@nfc.id}" class="last">
      <a href="/dal">NFC</a>
      <ul>
        <li id="section_#{@nfc_east.id}" class="first">
          <a href="/dal">East</a>
        </li>
        <li id="section_#{@nfc_north.id}">
          <a href="/chi">North</a>
        </li>
        <li id="section_#{@nfc_south.id}">
          <a href="/atl">South</a>
        </li>
        <li id="section_#{@nfc_west.id}" class="last">
          <a href="/ari">West</a>
        </li>
      </ul>
    </li>
  </ul>
</div>
HTML
    
    assert_equal expected, render_menu(:depth => 2, :show_all_siblings => true)
    
    expected = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc.id}" class="first open">
      <a href="/buf">AFC</a>
    </li>
    <li id="section_#{@nfc.id}" class="last">
      <a href="/dal">NFC</a>
    </li>
  </ul>
</div>
HTML
    
    assert_equal expected, render_menu(:depth => 1)
    
    expected = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc_east.id}" class="first">
      <a href="/buf">East</a>
    </li>
    <li id="section_#{@afc_north.id}" class="open">
      <a href="/bal">North</a>
    </li>
    <li id="section_#{@afc_south.id}">
      <a href="/hou">South</a>
    </li>
    <li id="section_#{@afc_west.id}" class="last">
      <a href="/den">West</a>
    </li>
  </ul>
</div>
HTML
    
    assert_equal expected, render_menu(:from_top => 1, :depth => 1)
    
  end
  
  def test_menu_with_links
    Page.first.update_attributes(:hidden => true, :publish_on_save => true)
    
    @news = Factory(:section, :parent => root_section, :name => "News", :path => "/whatever")
    @press_releases = Factory(:page, :section => @news, :name => "Press Releases", :path => "/press_releases", :publish_on_save => true)
    @corporate_news = Factory(:link, :section => @news, :name => "Corporate News", :url => "/news", :new_window => false, :publish_on_save => true)
    @cnn = Factory(:link, :section => @news, :name => "CNN", :url => "http://www.cnn.com", :new_window => true, :publish_on_save => true)
    expected = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@news.id}" class="first open">
      <a href="/press_releases">News</a>
      <ul>
        <li id="page_#{@press_releases.id}" class="first on">
          <a href="/press_releases">Press Releases</a>
        </li>
        <li id="link_#{@corporate_news.id}">
          <a href="/news">Corporate News</a>
        </li>
        <li id="link_#{@cnn.id}" class="last">
          <a href="http://www.cnn.com" target="_blank">CNN</a>
        </li>
      </ul>
    </li>
  </ul>
</div>
HTML
    
    @page = @press_releases
    output = render_menu
    assert_equal expected, output
    
  end
  
  def test_render_menu_does_not_show_unpublished_pages
    @section = Factory(:section, :name => "Test", :path => "/test")
    @page = Factory(:page, :section => @section, :name => "Overview", :path => "/test", :publish_on_save => true)

    @draft_page = Factory(:page, :section => @section, :name => "Draft v1", :path => "/draft", :publish_on_save => true)
    @draft_page.update_attributes(:name => "Draft v2")    
    @never_published = Factory(:page, :section => @section, :name => "Never Published", :path => "/never_published")
    output = render_menu(:from_top => 1)

    assert output =~ /\/test/, "Overview page should show up"
    assert output =~ /Draft v1/, "Original version of draft page should show up"
    assert output !~ /\/never_published/, "Never published should not show up"
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

    end
  
end