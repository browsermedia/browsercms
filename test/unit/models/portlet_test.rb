require File.join(File.dirname(__FILE__), '/../../test_helper')

# For some reason, these Portlet classes cannot be defined within the PortletTest class. Something
# related to the dynamic attributes causes other tests to fail.
class NoInlinePortlet < Portlet
  render_inline false
end
class InlinePortlet < Portlet
end

class NonEditablePortlet < Portlet
  enable_template_editor false
end

class EditablePortlet < Portlet
  enable_template_editor true
end


class PortletTest < ActiveSupport::TestCase

  def test_dynamic_attributes
    portlet = DynamicPortlet.create(:name => "Test", :foo => "FOO")
    assert_equal "FOO", Portlet.find(portlet.id).foo
    assert_equal "Dynamic Portlet", portlet.portlet_type_name
  end

  def test_portlets_consistently_load_the_same_number_of_types

    list = Portlet.types
    assert list.size > 0

    DynamicPortlet.create!(:name=>"test 1")
    DynamicPortlet.create!(:name=>"test 2")

    assert_equal list.size, Portlet.types.size
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
end