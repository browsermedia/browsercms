require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::PathHelperTest < ActionView::TestCase
  def setup
  end

  def teardown
  end


  def test_edit_cms_connectable_path_for_html
    block = HtmlBlock.create!(:name=>"Testing")
    path = edit_cms_connectable_path(block)

    assert_equal "/cms/html_blocks/#{block.id}/edit", path
  end


  def test_edit_cms_connectable_path_for_portlets
    portlet = DynamicPortlet.create(:name => "Testing Route generation")
    path = edit_cms_connectable_path(portlet)

    assert_equal( edit_cms_portlet_path(portlet), path )
  end

  def test_edit_cms_connectable_path_includes_options_for_html
    block = HtmlBlock.create!(:name=>"Testing")
    path = edit_cms_connectable_path(block, :_redirect_to => "some_path")

    assert_equal "/cms/html_blocks/#{block.id}/edit?_redirect_to=some_path", path

  end

  def test_edit_cms_connectable_path_includes_options_for_portlets
    portlet = DynamicPortlet.create(:name => "Testing Route generation")
    path = edit_cms_connectable_path(portlet, :_redirect_to => "/some_path")

    assert_equal( edit_cms_portlet_path(portlet, :_redirect_to => "/some_path"), path )
  end


  #
  #   This is a test to confirm in my head how polymorphic path building works in rails.
  #   It also confirms that it still works as expected in the future, as these don't seem
  #   like common methods to be used, and may be subject to breakage.
  #
  def test_how_rails_path_building_works
    block = HtmlBlock.create!(:name=>"Name")
    assert_equal "/cms/html_blocks/#{block.id}/edit", url_for([:edit, :cms, block])
    assert_equal "/cms/html_blocks/#{block.id}/edit", polymorphic_path([:edit, :cms, block])
    assert_equal "/cms/html_blocks/#{block.id}/edit?redirect_to=go_here", polymorphic_path([:edit, :cms, block], :redirect_to=>"go_here")
  end




end