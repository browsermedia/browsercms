require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::PageHelper do
  describe "render_breacrumbs" do
    before do
      @foo = create_section(:name => "Foo", :parent => root_section)
      create_page(:name => "Overview", :section => @foo, :path => "/foo")
      @bar = create_section(:name => "Bar", :parent => @foo)
      @bang = create_page(:name => "Bang", :section => @bar, :path => "/bang")
      
      assigns[:page] = @bang
    end
    it "should produce the desired output" do
      expected = <<HTML
<ul class="breadcrumbs">
  <li class="first"><a href="/">My Site</a></li>
  <li><a href="/foo">Foo</a></li>
  <li><a href="/bang">Bar</a></li>
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
  <li><a href="/bang">Bar</a></li>
  <li>Bang</li>
</ul>
HTML
      actual = helper.render_breadcrumbs(:from_top => 1)
      log "Expected:\n#{expected}"
      log "Actual:\n#{actual}"
      actual.should == expected.chomp
  
    end
  end
end