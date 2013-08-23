require 'test_helper'

# These Portlet classes cannot be defined within the PortletTest class. Something
# related to the dynamic attributes causes other tests to fail otherwise.
class NoInlinePortlet < Cms::Portlet
  render_inline false
  description "Tests #render_inline"
end

class InlinePortlet < Cms::Portlet
end

class NonEditablePortlet < Cms::Portlet
  enable_template_editor false
end

class EditablePortlet < Cms::Portlet
  enable_template_editor true
  description "Shows how you can create
    a multiline description."

end


class PortletTest < ActiveSupport::TestCase

  def setup
    @portlet = create(:portlet)

  end

  test ".description" do
    assert_equal "Tests #render_inline", NoInlinePortlet.description
    assert_not_nil EditablePortlet.description
  end

  test ".description when missing" do
    assert_equal "(No description available)", NonEditablePortlet.description
  end
  test "Users should able_to_modify? portlets" do
    user = create(:content_editor)
    assert_equal [], Cms::Portlet.new.connected_pages
    assert user.able_to_modify?(Cms::Portlet.new)

  end

  test "destroy should mark a portlet as deleted" do
    @portlet.destroy
    @portlet.reload!
    assert_equal true, @portlet.deleted?
  end

  test "update_attributes" do
    @portlet.update_attributes(:b => "whatever")
    assert_equal "whatever", @portlet.b
  end

  test "attributes=" do
    @portlet.attributes=({:b => "b"})
    assert_equal "b", @portlet.b
  end

  def test_dynamic_attributes
    portlet = DynamicPortlet.create(:name => "Test", :foo => "FOO")
    assert_equal "FOO", Cms::Portlet.find(portlet.id).foo
    assert_equal "Dynamic Portlet", portlet.portlet_type_name
  end

  test ".types is alphabetical" do
    assert_equal DynamicPortlet, Cms::Portlet.types.first
  end

  test ".types returns a list of portlet classes" do
    types = Cms::Portlet.types
    assert types.first.is_a? Class
    assert types.include? LoginPortlet
  end

  test ".underscore" do
    assert_equal "inline_portlet", InlinePortlet.name.underscore
  end


  def test_portlets_consistently_load_the_same_number_of_types

    list = Cms::Portlet.types
    assert list.size > 0

    DynamicPortlet.create!(:name=>"test 1")
    DynamicPortlet.create!(:name=>"test 2")

    assert_equal list.size, Cms::Portlet.types.size
  end


  test "render_inline" do
    assert_equal false, NoInlinePortlet.render_inline
  end

  test "Portlets should default to render_inline is true" do
    assert InlinePortlet.render_inline
  end

  test "allow_template_editing" do
    assert_equal true, EditablePortlet.render_inline

    assert_equal false, NonEditablePortlet.render_inline
  end

  test "If render_inline is true, should return the value of 'template'" do
    p = EditablePortlet.new
    p.template = "<b>CODE HERE</b>"

    assert_equal p.template, p.inline_options[:inline]
  end
  test "If render_inline is true, but template is blank, don't render inline" do
    p = EditablePortlet.new

    p.template = nil
    assert_equal({}, p.inline_options)

    p.template = ""
    assert_equal({}, p.inline_options)
  end

  test "Portlets should be considered 'connectable?, and therefore can have a /usages route.'" do
    assert Cms::Portlet.connectable?
  end
end
