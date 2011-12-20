require 'test_helper'

# Sample Model for testing naming/model classes
class Kindness < ActiveRecord::Base
  acts_as_content_block
end

class ReallyLongNameClass < ActiveRecord::Base
  acts_as_content_block

  def self.display_name
    "Short"
  end

  def self.display_name_plural
    "Shorteez"
  end
end

module Cms
  class NamespacedBlock < ActiveRecord::Base
    acts_as_content_block
  end
end

class Unnamespaced < ActiveRecord::Base
    acts_as_content_block
end

class Widget < ActiveRecord::Base
    acts_as_content_block
end

class ContentTypeTest < ActiveSupport::TestCase
  def setup
    @c = Cms::ContentType.new(:name => "ReallyLongNameClass")
    @unnamespaced_type = Cms::ContentType.create!(:name => "Unnamespaced", :group_name=>"Core")
  end


  test "#form for unnamespaced blocks" do
    widget_type =  Cms::ContentType.create!(:name => "Widget", :group_name=>"Core")
    assert_equal "cms/widgets/form", widget_type.form
  end

  test "template_path" do
    assert_equal "cms/widgets/render", Widget.template_path
  end

  test "find_by_key checks multiple namespaces" do
    assert_equal @unnamespaced_type, Cms::ContentType.find_by_key("Unnamespaced")
  end

  test "model_resource_name" do
    assert_equal "really_long_name_class", @c.model_class_form_name
  end

  test "Project specific routes should be still be namespaced under cms_" do
    assert_equal "main_app.cms_unnamespaced", @unnamespaced_type.route_name
  end

  test "route_name removes cms_ as prefix (no longer needed for engines)" do
    content_type = Cms::ContentType.new(:name=>"Cms::NamespacedBlock")
    assert_equal "namespaced_block", content_type.route_name
  end

  test "engine_for using Class" do
    assert_equal "main_app", Cms::ContentType.new.engine(Unnamespaced)
  end

  test "path_elements for instance of block" do
    u = mock()
    Cms::ContentType.any_instance.expects(:engine).returns("main_app")
    u.expects(:instance_of?).with(Class).returns(false).at_least_once
    assert_equal ["cms", u], Cms::ContentType.new.path_elements(u)
  end

  test "path_elements for a ContentType" do
    assert_equal ["cms", Unnamespaced], @unnamespaced_type.path_elements
  end

  def test_model_class
    assert_equal ReallyLongNameClass, @c.model_class
  end

  test "creating self.display_name on content block will set display_name on content type" do
    assert_equal "Short", @c.display_name
  end

  test "creating self.display_name_plural on content block will set display_name_plural on content type" do
    assert_equal "Shorteez", @c.display_name_plural
  end

  def test_content_block_type
    assert_equal "really_long_name_classes", @c.content_block_type
  end

  test "find_by_key handles names that end with s correctly" do
    Cms::ContentType.create!(:name => "Kindness", :group_name => "Anything")

    ct = Cms::ContentType.find_by_key("kindness")
    assert_not_nil ct
    assert_equal "Kindness", ct.display_name
  end

  test "calculate the model_class name with s" do
    ct = Cms::ContentType.new(:name=>"Kindness")
    assert_equal Kindness, ct.model_class
  end


end

