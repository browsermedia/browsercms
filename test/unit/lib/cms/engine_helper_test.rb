require "test_helper"

module Cms
  class CoreContentBlock
    extend Cms::Concerns::HasContentType
    has_content_type

    def self.connectable?
      false
    end

    def self.addressable?
      false
    end
    extend ::ActiveModel::Naming
  end
end

module Dummy
  class MainAppThing
    extend ::ActiveModel::Naming
  end
end

class UnnamespacedBlock
  extend ::ActiveModel::Naming
end

class PortletSubclass < Cms::Portlet

end

module BcmsWidgets
  class Engine < Rails::Engine
  end
  class ContentBlock
    extend ::ActiveModel::Naming
  end
end

class BcmsParts
  class ContentThing
    extend ::ActiveModel::Naming
  end
end

module ExpectedMockViews

  def view_for_cms_engine
    mock_view.expects(:cms).returns(:cms_engine)
    mock_view
  end

  def view_for_main_app
    mock_view.expects(:main_app).returns(:main_app)
    mock_view
  end

  def view_for_bcms_widgets_engine
    mock_view.expects(:bcms_widgets_engine).returns(:bcms_widgets_engine)
    mock_view
  end

  def mock_view
    return @view if @view
    @view = stub()
  end
end

module Cms
  class EngineHelperTest < ActiveSupport::TestCase

    test "#module_name" do
      assert_equal "Cms", EngineAware.module_name(Cms::CoreContentBlock)
      assert_nil EngineAware.module_name(UnnamespacedBlock)
      assert_equal "BcmsWidgets", EngineAware.module_name(BcmsWidgets::ContentBlock)
    end

  end


  class ContentBlocksEnginePathsTest < ActiveSupport::TestCase
    include ExpectedMockViews

    def setup
      @pathbuilder = EngineAwarePathBuilder.new(Cms::CoreContentBlock)
    end

    test "subject_class" do
      assert_equal Cms::CoreContentBlock, @pathbuilder.subject_class
    end

    test "#engine for applications" do
      assert_equal Rails.application, path_builder(Dummy::MainAppThing).engine_class
    end

    test "#engine for core Cms types" do
      assert_equal Cms::Engine, path_builder(Cms::CoreContentBlock).engine_class
    end

    test "#engine for Engines" do
      assert_equal BcmsWidgets::Engine, path_builder(BcmsWidgets::ContentBlock).engine_class
    end

    test "#engine_name" do
      assert_equal "cms", path_builder(Cms::CoreContentBlock).engine_name
    end

    test "#engine_name for models with no matching engine" do
      assert_equal "main_app", path_builder(BcmsParts::ContentThing).engine_name
    end

    test "#engine_name for models from engine engine" do
      assert_equal BcmsWidgets::Engine.engine_name, path_builder(BcmsWidgets::ContentBlock).engine_name
    end

    test "#engine_name for classes that support PolymorphicSTI" do
      assert_equal "cms", path_builder(PortletSubclass).engine_name
    end

    test "#engine_name for unnamespaced blocks" do
      assert_equal "main_app", path_builder(UnnamespacedBlock).engine_name
    end

    test "#main_app?" do
      assert_equal true, path_builder(Dummy::MainAppThing).main_app_model?
      assert_equal false, path_builder(Cms::CoreContentBlock).main_app_model?
      assert_equal false, path_builder(BcmsWidgets::ContentBlock).main_app_model?
    end

    test "build for Core Cms class" do
      assert_equal [:cms_engine, Cms::CoreContentBlock], @pathbuilder.build(view_for_cms_engine)
    end


    private

    def path_builder(klass)
      EngineAwarePathBuilder.new(klass)
    end

  end

  class PathsWithContentTypeTest < ActiveSupport::TestCase
    include ExpectedMockViews

    def setup
      ct = Cms::CoreContentBlock.content_type
      @pathbuilder = EngineAwarePathBuilder.new(ct)
    end

    test "build for contenttype" do
      assert_equal [:cms_engine, Cms::CoreContentBlock], @pathbuilder.build(view_for_cms_engine)
    end
  end

  class EngineAwarePathsTest < ActiveSupport::TestCase
    include ExpectedMockViews
    test "build for custom block class" do
      pathbuilder = EngineAwarePathBuilder.new(Dummy::MainAppThing)
      assert_equal [:main_app, Dummy::MainAppThing], pathbuilder.build(view_for_main_app)
    end

    test "paths for block from a module" do
      pathbuilder = EngineAwarePathBuilder.new(BcmsWidgets::ContentBlock)
      assert_equal [:bcms_widgets_engine, BcmsWidgets::ContentBlock], pathbuilder.build(view_for_bcms_widgets_engine)
    end

    test "build for model" do
      block = Cms::CoreContentBlock.new
      pathbuilder = EngineAwarePathBuilder.new(block)
      assert_equal [:cms_engine, block], pathbuilder.build(view_for_cms_engine)
    end


  end

end