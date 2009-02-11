require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::PageHelper do
  describe "render_breacrumbs" do
    before do
      @foo = create_section(:name => "Foo", :parent => root_section, :path => "/foo")
      create_page(:name => "Overview", :section => @foo, :path => "/foo")
      @bar = create_section(:name => "Bar", :parent => @foo, :path => "/bar")
      @overview = create_page(:name => "Overview", :section => @bar, :path => "/bar")
      @bang = create_page(:name => "Bang", :section => @bar, :path => "/bar/bang")
      
      assigns[:page] = @bang
    end
    it "should produce the desired output" do
      expected = <<HTML
<ul class="breadcrumbs">
  <li class="first"><a href="/">My Site</a></li>
  <li><a href="/foo">Foo</a></li>
  <li><a href="/bar">Bar</a></li>
  <li>Bang</li>
</ul>
HTML
      actual = helper.render_breadcrumbs
      log "Expected:\n#{expected}"
      log "Actual:\n#{actual}"
      actual.should == expected.chomp

      expected = <<HTML
<ul class="breadcrumbs">
  <li class="first"><a href="/foo">Foo</a></li>
  <li><a href="/bar">Bar</a></li>
  <li>Bang</li>
</ul>
HTML
      actual = helper.render_breadcrumbs(:from_top => 1)
      log "Expected:\n#{expected}"
      log "Actual:\n#{actual}"
      actual.should == expected.chomp

      assigns[:page] = @overview

      expected = <<HTML
<ul class="breadcrumbs">
  <li class="first"><a href="/foo">Foo</a></li>
  <li>Bar</li>
</ul>
HTML
      actual = helper.render_breadcrumbs(:from_top => 1)
      log "Expected:\n#{expected}"
      log "Actual:\n#{actual}"
      actual.should == expected.chomp

      expected = <<HTML
<ul class="breadcrumbs">
  <li class="first"><a href="/foo">Foo</a></li>
  <li><a href="/bar">Bar</a></li>
  <li>Overview</li>
</ul>
HTML
      actual = helper.render_breadcrumbs(:from_top => 1, :show_parent => true)
      log "Expected:\n#{expected}"
      log "Actual:\n#{actual}"
      actual.should == expected.chomp

  
    end
  end
end