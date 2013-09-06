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

module BcmsStore
  class Engine < Rails::Engine
  end
  class Widget < ActiveRecord::Base
    acts_as_content_block
  end
end

class AudioTour < ActiveRecord::Base
  acts_as_content_block
end
class Tour < ActiveRecord::Base
  acts_as_content_block
end

module Cms

  class ContentTypeTest < ActiveSupport::TestCase

    test "ContentTypes with matching suffixes" do
      assert_equal Tour, Cms::ContentType.find_by_key('Tour').model_class
      assert_equal AudioTour, Cms::ContentType.find_by_key('AudioTour').model_class
    end

    test "#find_by_key searches Cms:: then non Cms:: namespace class" do
      assert_equal Product, Cms::ContentType.find_by_key('Cms::Product').model_class
    end

    test "#find_by_key using key" do
      assert_equal Cms::HtmlBlock, Cms::ContentType.find_by_key('html_block').model_class
    end


    test "#key" do
      assert_equal "really_long_name_class", long_name_content_type.key
    end

    test "#display_name for blocks from modules" do
      assert_equal "Widget", Cms::ContentType.new(:name => "BcmsStore::Widget").display_name
      assert_equal "Widget", BcmsStore::Widget.display_name
    end

    test "display_name for non-Cms classes" do
      assert_equal "String", Cms::ContentType.new(:name => "String").display_name
    end

    test "#form for unnamespaced blocks" do
      widget_type = Cms::ContentType.new(:name => "Widget")
      assert_equal "cms/widgets/form", widget_type.form
    end

    test "template_path" do
      assert_equal "cms/widgets/render", Widget.template_path
    end

    test "template_path for modules" do
      assert_equal "bcms_store/widgets/render", BcmsStore::Widget.template_path
    end

    test "find_by_key checks multiple namespaces" do
      assert_equal Unnamespaced, Cms::ContentType.find_by_key("Unnamespaced").model_class
    end

    test "model_resource_name" do
      assert_equal "really_long_name_class", long_name_content_type().model_class_form_name
    end

    test "Project specific routes should be still be namespaced under cms_" do
      assert_equal "main_app.cms_unnamespaced", Unnamespaced.content_type.route_name
    end

    test "route_name removes cms_ as prefix (no longer needed for engines)" do
      content_type = Cms::NamespacedBlock.content_type
      assert_equal "namespaced_block", content_type.route_name
    end

    test "engine_for using Class" do
      EngineHelper.decorate(Unnamespaced)
      assert_equal "main_app", Unnamespaced.engine_name
    end

    test "engine_name for Cms engine" do
      cms_namespace = Cms::ContentType.new(:name => "Cms::NamespacedBlock")
      assert_equal "cms", cms_namespace.engine_name
    end

    test "path_elements for Cms engine" do
      cms_namespace = Cms::ContentType.new(:name => "Cms::NamespacedBlock")
      assert_equal [Cms::NamespacedBlock], cms_namespace.path_elements
    end

    test "path_elements for an app ContentType" do
      assert_equal ["cms", Unnamespaced], unnamespaced_type().path_elements
    end

    def test_model_class
      assert_equal ReallyLongNameClass, long_name_content_type.model_class
    end

    test "creating self.display_name on content block will set display_name on content type" do
      assert_equal "Short", long_name_content_type.display_name
    end

    test "creating self.display_name_plural on content block will set display_name_plural on content type" do
      assert_equal "Shorteez", long_name_content_type.display_name_plural
    end

    def test_content_block_type
      assert_equal "really_long_name_classes", long_name_content_type.content_block_type
    end

    test "find_by_key handles names that end with s correctly" do

      ct = Cms::ContentType.find_by_key("kindness")
      assert_not_nil ct
      assert_equal "Kindness", ct.display_name
    end

    test "calculate the model_class name with s" do
      ct = Cms::ContentType.new(:name => "Kindness")
      assert_equal Kindness, ct.model_class
    end

    test "Form for Blocks with Engines" do
      engine_type = Cms::ContentType.new(:name => "BcmsStore::Widget")
      assert_equal true, engine_type.engine_exists?
      assert_equal "bcms_store/widgets/form", engine_type.form
    end

    test ".find_by_key with unnamespaced blocks" do
      type = Cms::ContentType.find_by_key("html_blocks")
      assert_equal Cms::HtmlBlock, type.model_class
    end

    def long_name_content_type
      ReallyLongNameClass.content_type
    end

    def unnamespaced_type
      Unnamespaced.content_type
    end
  end
end

# For testing find_by_key with pluralization
class Person < ActiveRecord::Base
  acts_as_content_block
end

module Cms

  class FindByKeyTest < ActiveSupport::TestCase

    test "ActiveSupport#classify automatically singularizes" do
      assert_equal "Person", "people".tableize.classify
      assert_equal "people", "people".tableize

    end

    test "#find_by_key with irregular pluralization" do

      type = Cms::ContentType.find_by_key("people")
      assert_not_nil type
      assert_equal "Person", type.display_name

    end
  end
end

