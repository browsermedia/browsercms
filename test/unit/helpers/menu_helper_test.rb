require 'test_helper'

module Cms
  class MenuHelperTest < ActionView::TestCase

    def test_menu_items
      given_a_sitemap_of_nfl_teams_exists

      expected = [
          {:id => "cms_section_#{@afc.id}", :url => "/buf", :name => "AFC", :children => [
              {:id => "cms_section_#{@afc_east.id}", :url => "/buf", :name => "East"},
              {:id => "cms_section_#{@afc_north.id}", :url => "/bal", :name => "North", :children => [
                  {:id => "cms_page_#{@bal.id}", :selected => true, :url => "/bal", :name => "Baltimore Ravens"},
                  {:id => "cms_page_#{@cin.id}", :url => "/cin", :name => "Cincinnati Bengals"},
                  {:id => "cms_page_#{@cle.id}", :url => "/cle", :name => "Cleveland Browns"},
                  {:id => "cms_page_#{@pit.id}", :url => "/pit", :name => "Pittsburgh Steelers"}
              ]},
              {:id => "cms_section_#{@afc_south.id}", :url => "/hou", :name => "South"},
              {:id => "cms_section_#{@afc_west.id}", :url => "/den", :name => "West"}
          ]},
          {:id => "cms_section_#{@nfc.id}", :url => "/dal", :name => "NFC"},
          {:id => "cms_section_#{@int.id}", :url => "/international", :name => "International"}
      ]

      assert_equal expected, menu_items(:page => @bal)

      @page = @bal
      assert_equal expected, menu_items

      expected = [
          {:id => "cms_section_#{@afc.id}", :url => "/buf", :name => "AFC", :children => [
              {:id => "cms_section_#{@afc_east.id}", :url => "/buf", :name => "East"},
              {:id => "cms_section_#{@afc_north.id}", :url => "/bal", :name => "North"},
              {:id => "cms_section_#{@afc_south.id}", :url => "/hou", :name => "South"},
              {:id => "cms_section_#{@afc_west.id}", :url => "/den", :name => "West"}
          ]},
          {:id => "cms_section_#{@nfc.id}", :url => "/dal", :name => "NFC"},
          {:id => "cms_section_#{@int.id}", :url => "/international", :name => "International"}
      ]

      assert_equal expected, menu_items(:depth => 2)

      expected = [
          {:id => "cms_section_#{@afc_east.id}", :url => "/buf", :name => "East"},
          {:id => "cms_section_#{@afc_north.id}", :url => "/bal", :name => "North", :children => [
              {:id => "cms_page_#{@bal.id}", :selected => true, :url => "/bal", :name => "Baltimore Ravens"},
              {:id => "cms_page_#{@cin.id}", :url => "/cin", :name => "Cincinnati Bengals"},
              {:id => "cms_page_#{@cle.id}", :url => "/cle", :name => "Cleveland Browns"},
              {:id => "cms_page_#{@pit.id}", :url => "/pit", :name => "Pittsburgh Steelers"}
          ]},
          {:id => "cms_section_#{@afc_south.id}", :url => "/hou", :name => "South"},
          {:id => "cms_section_#{@afc_west.id}", :url => "/den", :name => "West"}
      ]

      assert_equal expected, menu_items(:from_top => 1, :depth => 2)

      expected = [
          {:id => "cms_section_#{@afc.id}", :url => "/buf", :name => "AFC", :children => [
              {:id => "cms_section_#{@afc_east.id}", :url => "/buf", :name => "East"},
              {:id => "cms_section_#{@afc_north.id}", :url => "/bal", :name => "North"},
              {:id => "cms_section_#{@afc_south.id}", :url => "/hou", :name => "South"},
              {:id => "cms_section_#{@afc_west.id}", :url => "/den", :name => "West"}
          ]},
          {:id => "cms_section_#{@nfc.id}", :url => "/dal", :name => "NFC", :children => [
              {:id => "cms_section_#{@nfc_east.id}", :url => "/dal", :name => "East"},
              {:id => "cms_section_#{@nfc_north.id}", :url => "/chi", :name => "North"},
              {:id => "cms_section_#{@nfc_south.id}", :url => "/atl", :name => "South"},
              {:id => "cms_section_#{@nfc_west.id}", :url => "/ari", :name => "West"}
          ]},
          {:id => "cms_section_#{@int.id}", :url => "/international", :name => "International"}
      ]

      assert_equal expected, menu_items(:depth => 2, :show_all_siblings => true)

      expected = [
          {:id => "cms_section_#{@afc.id}", :url => "/buf", :name => "AFC"},
          {:id => "cms_section_#{@nfc.id}", :url => "/dal", :name => "NFC"},
          {:id => "cms_section_#{@int.id}", :url => "/international", :name => "International"}
      ]

      assert_equal expected, menu_items(:depth => 1)

      expected = [
          {:id => "cms_section_#{@afc_east.id}", :url => "/buf", :name => "East"},
          {:id => "cms_section_#{@afc_north.id}", :url => "/bal", :name => "North"},
          {:id => "cms_section_#{@afc_south.id}", :url => "/hou", :name => "South"},
          {:id => "cms_section_#{@afc_west.id}", :url => "/den", :name => "West"}
      ]

      assert_equal expected, menu_items(:from_top => 1, :depth => 1)

      expected = [
          {:id => "cms_section_#{@afc_east.id}", :url => "/buf", :name => "East"},
          {:id => "cms_section_#{@afc_north.id}", :url => "/bal", :name => "North"},
          {:id => "cms_section_#{@afc_south.id}", :url => "/hou", :name => "South"}
      ]

      assert_equal expected, menu_items(:from_top => 1, :depth => 1, :limit => 3)

      expected = [
          {:id => "cms_section_#{@afc.id}", :url => "/buf", :name => "AFC"},
          {:id => "cms_section_#{@nfc.id}", :url => "/dal", :name => "NFC"},
          {:id => "cms_section_#{@int.id}", :selected => true, :url => "/international", :name => "International"}
      ]

      assert_equal expected, menu_items(:page => @overview)

    end

    def test_menu_with_links

      @news = create(:section, :parent => root_section, :name => "News", :path => "/whatever")
      @press_releases = create(:page, :section => @news, :name => "Press Releases", :path => "/press_releases", :publish_on_save => true)
      @corporate_news = create(:link, :section => @news, :name => "Corporate News", :url => "/news", :new_window => false, :publish_on_save => true)
      @cnn = create(:link, :section => @news, :name => "CNN", :url => "http://www.cnn.com", :new_window => true, :publish_on_save => true)

      expected = [
          {:id => "cms_section_#{@news.id}", :url => "/press_releases", :name => "News", :children => [
              {:id => "cms_page_#{@press_releases.id}", :selected => true, :url => "/press_releases", :name => "Press Releases"},
              {:id => "cms_link_#{@corporate_news.id}", :url => "/news", :name => "Corporate News"},
              {:id => "cms_link_#{@cnn.id}", :url => "http://www.cnn.com", :target => "_blank", :name => "CNN"}
          ]}
      ]

      @page = @press_releases
      assert_equal expected, menu_items
      assert_equal [], menu_items(:from_top => 42)
    end

    def test_render_menu_does_not_show_unpublished_pages
      @section = create(:section, :name => "Test", :path => "/test")
      @page = create(:page, :section => @section, :name => "Overview", :path => "/test", :publish_on_save => true)

      @draft_page = create(:page, :section => @section, :name => "Draft v1", :path => "/draft", :publish_on_save => true)
      @draft_page.update_attributes(:name => "Draft v2", :publish_on_save => false)
      @never_published = create(:page, :section => @section, :name => "Never Published", :path => "/never_published", :publish_on_save=>false)

      expected = [
          {:id => "cms_page_#{@page.id}", :name => "Overview", :url => "/test", :selected => true},
          {:id => "cms_page_#{@draft_page.id}", :name => "Draft v1", :url => "/draft"}
      ]

      assert_equal expected, menu_items(:from_top => 1)
    end

    def test_render_menu_with_path
      @test = create(:page, :section => root_section, :name => "Test", :path => "/test", :publish_on_save => true)
      @footer = create(:section, :parent => root_section, :name => "Footer", :path => "/footer")
      @about_us = create(:page, :section => @footer, :name => "About Us", :path => "/about_us", :publish_on_save => true)
      @contact_us = create(:page, :section => @footer, :name => "Contact Us", :path => "/contact_us", :publish_on_save => true)
      @privacy_policy = create(:page, :section => @footer, :name => "Privacy Policy", :path => "/privacy_policy", :publish_on_save => true)
      assert_equal [root_section, @footer], Section.all, "Verifying there is only the expected seed data present"

      expected = [
          {:id => "cms_page_#{@about_us.id}", :url => "/about_us", :name => "About Us"},
          {:id => "cms_page_#{@contact_us.id}", :url => "/contact_us", :name => "Contact Us"},
          {:id => "cms_page_#{@privacy_policy.id}", :url => "/privacy_policy", :name => "Privacy Policy"}
      ]

      actual = menu_items(:page => @test, :path => "/footer", :from_top => 1)
      assert_equal expected, actual

      expected = [
          {:id => "cms_page_#{@about_us.id}", :url => "/about_us", :name => "About Us"},
          {:id => "cms_page_#{@contact_us.id}", :url => "/contact_us", :name => "Contact Us", :selected => true},
          {:id => "cms_page_#{@privacy_policy.id}", :url => "/privacy_policy", :name => "Privacy Policy"}
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
    def given_a_sitemap_of_nfl_teams_exists
      @afc = create(:section, :parent => root_section, :name => "AFC")

      @afc_east = create(:section, :parent => @afc, :name => "East")
      @buf = create(:page, :section => @afc_east, :name => "Buffalo Bills", :path => "/buf", :publish_on_save => true)
      @mia = create(:page, :section => @afc_east, :name => "Miami Dolphins", :path => "/mia", :publish_on_save => true)
      @ne = create(:page, :section => @afc_east, :name => "New England Patriots", :path => "/ne", :publish_on_save => true)
      @nyj = create(:page, :section => @afc_east, :name => "New York Jets", :path => "/nyj", :publish_on_save => true)

      @afc_north = create(:section, :parent => @afc, :name => "North")
      @bal = create(:page, :section => @afc_north, :name => "Baltimore Ravens", :path => "/bal", :publish_on_save => true)
      @cin = create(:page, :section => @afc_north, :name => "Cincinnati Bengals", :path => "/cin", :publish_on_save => true)
      @cle = create(:page, :section => @afc_north, :name => "Cleveland Browns", :path => "/cle", :publish_on_save => true)
      @pit = create(:page, :section => @afc_north, :name => "Pittsburgh Steelers", :path => "/pit", :publish_on_save => true)

      @afc_south = create(:section, :parent => @afc, :name => "South")
      @hou = create(:page, :section => @afc_south, :name => "Houston Texans", :path => "/hou", :publish_on_save => true)
      @ind = create(:page, :section => @afc_south, :name => "Indianapolis Colts", :path => "/ind", :publish_on_save => true)
      @jac = create(:page, :section => @afc_south, :name => "Jacksonville Jaguars", :path => "/jac", :publish_on_save => true)
      @ten = create(:page, :section => @afc_south, :name => "Tennessee Titans", :path => "/ten", :publish_on_save => true)

      @afc_west = create(:section, :parent => @afc, :name => "West")
      @den = create(:page, :section => @afc_west, :name => "Denver Broncos", :path => "/den", :publish_on_save => true)
      @kc = create(:page, :section => @afc_west, :name => "Kansas City Chiefs", :path => "/kc", :publish_on_save => true)
      @oak = create(:page, :section => @afc_west, :name => "Oakland Raiders", :path => "/oak", :publish_on_save => true)
      @sd = create(:page, :section => @afc_west, :name => "San Diego Chargers", :path => "/sd", :publish_on_save => true)

      @nfc = create(:section, :parent => root_section, :name => "NFC")

      @nfc_east = create(:section, :parent => @nfc, :name => "East")
      @dal = create(:page, :section => @nfc_east, :name => "Dallas Cowboys", :path => "/dal", :publish_on_save => true)
      @nyg = create(:page, :section => @nfc_east, :name => "New York Giants", :path => "/nyg", :publish_on_save => true)
      @phi = create(:page, :section => @nfc_east, :name => "Philadelphia Eagles", :path => "/phi", :publish_on_save => true)
      @was = create(:page, :section => @nfc_east, :name => "Washington Redskins", :path => "/was", :publish_on_save => true)

      @nfc_north = create(:section, :parent => @nfc, :name => "North")
      @chi = create(:page, :section => @nfc_north, :name => "Chicago Bears", :path => "/chi", :publish_on_save => true)
      @det = create(:page, :section => @nfc_north, :name => "Detroit Lions", :path => "/det", :publish_on_save => true)
      @gb = create(:page, :section => @nfc_north, :name => "Green Bay Packers", :path => "/gb", :publish_on_save => true)
      @min = create(:page, :section => @nfc_north, :name => "Minnesota Vikings", :path => "/min", :publish_on_save => true)

      @nfc_south = create(:section, :parent => @nfc, :name => "South")
      @atl = create(:page, :section => @nfc_south, :name => "Atlanta Falcons", :path => "/atl", :publish_on_save => true)
      @car = create(:page, :section => @nfc_south, :name => "Carolina Pathers", :path => "/car", :publish_on_save => true)
      @no = create(:page, :section => @nfc_south, :name => "New Orleans Saints", :path => "/no", :publish_on_save => true)
      @tb = create(:page, :section => @nfc_south, :name => "Tampa Bay Buccaneers", :path => "/tb", :publish_on_save => true)

      @nfc_west = create(:section, :parent => @nfc, :name => "West")
      @ari = create(:page, :section => @nfc_west, :name => "Arizona Cardinals", :path => "/ari", :publish_on_save => true)
      @sf = create(:page, :section => @nfc_west, :name => "San Francisco 49ers", :path => "/sf", :publish_on_save => true)
      @sea = create(:page, :section => @nfc_west, :name => "Seattle Seahawks", :path => "/sea", :publish_on_save => true)
      @stl = create(:page, :section => @nfc_west, :name => "St. Louis Rams", :path => "/stl", :publish_on_save => true)

      @int = create(:section, :parent => root_section, :name => "International", :path => '/international')
      @overview = create(:page, :section => @int, :name => "Overview", :path => "/international", :publish_on_save => true, :hidden => true)
    end


  end
end