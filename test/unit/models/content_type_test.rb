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

module Dummy
  class Widget < ActiveRecord::Base
    acts_as_content_block
  end
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

    test "#find_by_key finds namespaced models" do
      assert_equal Dummy::Product, Cms::ContentType.find_by_key('Dummy::Product').model_class
    end

    test "#find_by_key finds namespace models by underscorized keys" do
      assert_equal Dummy::Product, Cms::ContentType.find_by_key('dummy/products').model_class
    end

    test "#find_by_key using key" do
      assert_equal Cms::HtmlBlock, Cms::ContentType.find_by_key('html_block').model_class
    end

    test ".orderable_attributes" do
      orderable_columns = Cms::HtmlBlock.content_type.orderable_attributes
      assert orderable_columns.include?("name")
      refute orderable_columns.include?("id")
    end

    test "#content_block_type" do
      assert_equal "html_blocks", Cms::HtmlBlock.content_type.content_block_type
      assert_equal "dummy/products", Dummy::Product.content_type.content_block_type
    end

    test "#display_name for blocks from modules" do
      assert_equal "Widget", Cms::ContentType.new(:name => "BcmsStore::Widget").display_name
      assert_equal "Widget", BcmsStore::Widget.display_name
    end

    test "display_name for non-Cms classes" do
      assert_equal "String", Cms::ContentType.new(:name => "String").display_name
    end

    test "#form for Core modules" do
      widget_type = Cms::ContentType.new(:name => "Dummy::Widget")
      assert_equal "dummy/widgets/form", widget_type.form
    end

    test "template_path" do
      assert_equal "dummy/widgets/render", Dummy::Widget.template_path
    end

    test "template_path for modules" do
      assert_equal "bcms_store/widgets/render", BcmsStore::Widget.template_path
    end

    test "find_by_key checks multiple namespaces" do
      assert_equal Unnamespaced, Cms::ContentType.find_by_key("Unnamespaced").model_class
    end

    test "#param_key" do
      assert_equal "really_long_name_class", long_name_content_type.param_key
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

  class EngineAwareMethodsTest < ActiveSupport::TestCase


    test "#path_builder" do
      assert_equal EngineAwarePathBuilder, path_builder.class
      assert_equal Dummy::Widget, path_builder.subject_class
    end

    test "#engine_class" do
      path_builder.expects(:engine_class).returns(:expected_value)
      assert_equal :expected_value, content_type.engine_class
    end

    test "#engine_name" do
      path_builder.expects(:engine_name).returns(:expected_value)
      assert_equal :expected_value, content_type.engine_name
    end

    test "#main_app_model?" do
      path_builder.expects(:main_app_model?).returns(:expected_value)
      assert_equal :expected_value, content_type.main_app_model?
    end

    private

    def path_builder
      @path_builder ||= content_type.path_builder
    end

    def content_type
      @content_type ||= Dummy::Widget.content_type
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

