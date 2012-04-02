require 'test_helper'

class Cms::PageHelperTest < ActionView::TestCase

  def setup
    root_section.name = "My Site"
    root_section.save!
    @foo = create(:section, :name => "Foo", :parent => root_section, :path => "/foo")
    create(:page, :name => "Overview", :section => @foo, :path => "/foo")
    @bar = create(:section, :name => "Bar", :parent => @foo, :path => "/bar")
    @overview = create(:page, :name => "Overview", :section => @bar, :path => "/bar")
    @bang = create(:page, :name => "Bang", :section => @bar, :path => "/bar/bang")

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