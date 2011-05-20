require 'test_helper'

class Parent
  def render
    "I'm the 'wrong' render method to call."
  end
end

class SelfRenderingBlock < Parent
  include Cms::Behaviors::Rendering
  is_renderable

  def render
    "I can do it myself"
  end
end

class NonSelfRenderingBlock < Parent
  include Cms::Behaviors::Rendering
  is_renderable
end

class RenderingTest < ActiveSupport::TestCase

  test "an object should not self render if it doesn't define a 'render' method on the class itself." do
    obj = NonSelfRenderingBlock.new
    assert_equal false, obj.should_render_self?
  end

  test "an object should self render if it defines a 'render' method." do
    obj = SelfRenderingBlock.new
    assert_equal true, obj.should_render_self?
  end

  test "The proper render method should be called" do
    assert_equal false, Cms::HtmlBlock.new.should_render_self?, "HtmlBlocks should not be considered 'self renderable'"
  end

  test "Blocks which define their own render method should have that one called" do
    assert_equal "I can do it myself", SelfRenderingBlock.new.render
  end

  test "prepare_to_render should not call 'render' when blocks are non-self rendering" do
    non_rendering = NonSelfRenderingBlock.new
    non_rendering.expects(:should_render_self?).returns(false)
    non_rendering.expects(:render).never
    non_rendering.prepare_to_render(stub())

  end

  test "prepare to render" do
    self_rendering = SelfRenderingBlock.new
    self_rendering.expects(:render)
    self_rendering.prepare_to_render(stub())
  end

  test "perform render doesn't throw missing methods errors" do
    controller = ActionController::Base.new
    controller.expects(:view_paths).returns([])

    block = Cms::HtmlBlock.new

    # This isn't really what should happen, but its at least testing that render isn't using missing methods
    assert_raise ActionView::MissingTemplate do
      block.perform_render(controller)
    end
  end
end