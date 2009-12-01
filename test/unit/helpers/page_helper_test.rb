require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::PageHelperTest < ActionView::TestCase

  def setup
    @foo = Factory(:section, :name => "Foo", :parent => root_section, :path => "/foo")
    Factory(:page, :name => "Overview", :section => @foo, :path => "/foo")
    @bar = Factory(:section, :name => "Bar", :parent => @foo, :path => "/bar")
    @overview = Factory(:page, :name => "Overview", :section => @bar, :path => "/bar")
    @bang = Factory(:page, :name => "Bang", :section => @bar, :path => "/bar/bang")

    @page = @bang
  end
  
  def test_render_breadcrumbs
    expected = <<HTML
<ul class="breadcrumbs">
  <li class="first"><a href="/">My Site</a></li>
  <li><a href="/foo">Foo</a></li>
  <li><a href="/bar">Bar</a></li>
  <li>Bang</li>
</ul>
HTML
    
    assert_equal expected.chomp, render_breadcrumbs
    
    expected = <<HTML
<ul class="breadcrumbs">
  <li class="first"><a href="/foo">Foo</a></li>
  <li><a href="/bar">Bar</a></li>
  <li>Bang</li>
</ul>
HTML

    assert_equal expected.chomp, render_breadcrumbs(:from_top => 1)

    @page = @overview

    expected = <<HTML
<ul class="breadcrumbs">
  <li class="first"><a href="/foo">Foo</a></li>
  <li>Bar</li>
</ul>
HTML
    
    assert_equal expected.chomp, render_breadcrumbs(:from_top => 1)

    expected = <<HTML
<ul class="breadcrumbs">
  <li class="first"><a href="/foo">Foo</a></li>
  <li><a href="/bar">Bar</a></li>
  <li>Overview</li>
</ul>
HTML
    
    assert_equal expected.chomp, render_breadcrumbs(:from_top => 1, :show_parent => true)
  end  
  
  test "A missing @page should cause the breadcrumbs to render nothing, which may occur in TemplateSupport or Acts::ContentPage." do
    @page = nil

    assert_equal "", render_breadcrumbs
  end
  
end