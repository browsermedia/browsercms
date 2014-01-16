require "minitest_helper"

class Widget < ActiveRecord::Base
  acts_as_content_block
  content_module :widgets
end


class JustHasContentType < ActiveRecord::Base
  has_content_type module: :widgets
end

class AAAFirstBlock < ActiveRecord::Base
  acts_as_content_block
end

describe Cms::ContentType do

  describe '#module_name' do
    it "returns a :symbol that groups related content types." do
      type = Cms::ContentType.new(name: 'Cms::HtmlBlock')
      type.module_name.must_equal :core
    end

    it "can be configured in the content block" do
      type = Cms::ContentType.new(name: 'Widget')
      assert_equal :widgets, type.module_name
    end

    it "should default to :general if not specified" do
      type = Cms::ContentType.new(name: 'AAAFirstBlock')
      assert_equal :general, type.module_name
    end

    it "can be specified as argument to has_content_type" do
      JustHasContentType.content_type.module_name.must_equal :widgets
    end
  end

  describe '.available_by_module' do
    it "should return a list of modules in alphabetical order" do
      modules = Cms::ContentType.available_by_module
      modules.keys.sort.first.must_equal :categorization
      modules[:core].map { |t| t.name }.must_include 'Cms::HtmlBlock'
    end

  end

  describe '.content_type' do
    it "should return ContentType info" do
      content_type = Widget.content_type
      content_type.must_be_instance_of Cms::ContentType
      content_type.name.must_equal "Widget"
    end
  end

  describe '.default' do
    it "should return the basic content type" do
      default_type = Cms::ContentType.default
      default_type.name.must_equal "Cms::HtmlBlock"
    end
  end

  describe '#connectable?' do
    it "should mark content_types as connectable to pages" do
      Cms::HtmlBlock.content_type.connectable?.must_equal true
      Dummy::Product.content_type.connectable?.must_equal true

      [Cms::Category, Cms::Tag, Cms::CategoryType].each do |unconnectable|
        unconnectable.content_type.connectable?.must_equal false
      end
      Cms::Category.content_type.connectable?.must_equal false
      Cms::CategoryType.content_type.connectable?.must_equal false
    end
  end

  describe '.named' do
    it "should return the content type based on the class name" do
      type = Cms::ContentType.named('Cms::HtmlBlock')
      type.first.model_class.must_equal Cms::HtmlBlock
    end
  end

  describe '.connectable' do
    it "should return only content blocks can be added to pages" do
      connectable = Cms::ContentType.connectable
      names_of_connectables = connectable.map {|c| c.name}
      names_of_connectables.must_include 'Cms::HtmlBlock'
      names_of_connectables.wont_include 'Cms::Category'
    end


  end
  describe '.other_connectables' do
    it "should return all types but the default" do
      others = Cms::ContentType.other_connectables
      others.collect { |ct| ct.name }.wont_include("Cms::HtmlBlock")
      (others.size + 1).must_equal(Cms::ContentType.available.size)
    end
  end

  describe '.addressable' do
    it "should return only content types that can act as pages" do
      names = Cms::ContentType.addressable.map {|c| c.name}
      names.must_include("Dummy::Product")
      names.wont_include("Cms::HtmlBlock")
    end
  end

  describe '.user_generated_connectables' do
    it "should return only user generated content types" do
      user_gen = Cms::ContentType.user_generated_connectables
      user_gen.collect { |ct| ct.name }.wont_include("Cms::HtmlBlock")
      user_gen.collect { |ct| ct.name }.wont_include("Cms::Category")
      user_gen.collect { |ct| ct.name }.wont_include("Cms::CategoryType")
      user_gen.collect { |ct| ct.name }.wont_include("Cms::Tag")
      user_gen.collect { |ct| ct.name }.wont_include("Cms::ImageBlock")
      user_gen.collect { |ct| ct.name }.wont_include("Cms::FileBlock")
      user_gen.collect { |ct| ct.name }.wont_include("Cms::Portlet")
    end
  end

  describe '.available' do

    it "should include categories" do
      content_type_names.must_include "Cms::Category"
      content_type_names.must_include "Cms::CategoryType"
      content_type_names.must_include "Cms::Tag"

    end
    it "should not include Link (which is more of a page type)" do
      content_type_names.wont_include 'Cms::Link'
    end

    it "should exclude descendants of portlets" do
      given_login_portlet_has_been_loaded_as_constant_by_rails
      content_type_names.wont_include "LoginPortlet"
      content_type_names.must_include "Cms::Portlet"

    end
    it "should return all available content types" do
      types = Cms::ContentType.available
      types.first.class.must_equal Cms::ContentType
    end

    it "should be ordered alphabetically" do
      content_type_names.first.must_equal "AAAFirstBlock"
      content_type_names.last.must_equal "Widget"
    end


  end

  def content_type_names
    @types ||= Cms::ContentType.available.map { |t| t.name }
  end

  # Support
  def given_login_portlet_has_been_loaded_as_constant_by_rails
    LoginPortlet
  end
end

