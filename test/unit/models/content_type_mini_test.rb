require "minitest_helper"

class Widget < ActiveRecord::Base
  acts_as_content_block
  content_module :widgets
end


class AAAFirstBlock < ActiveRecord::Base
  acts_as_content_block
end

def given_login_portlet_has_been_loaded_as_constant_by_rails
  LoginPortlet
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
  end

  describe '.available_by_module' do
    it "should return a list of modules in alphabetical order" do
      modules = Cms::ContentType.available_by_module
      modules.keys.sort.first.must_equal :core
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

  describe '.other_connectables' do
    it "should return all types but the default" do
      others = Cms::ContentType.other_connectables
      others.collect { |ct| ct.name }.wont_include("Cms::HtmlBlock")
      (others.size + 1).must_equal(Cms::ContentType.available.size)
    end
  end

  describe '.available' do
    it "should exclude descendants of portlets" do
      given_login_portlet_has_been_loaded_as_constant_by_rails
      type_names = Cms::ContentType.available.map { |t| t.name }
      type_names.wont_include "LoginPortlet"
      type_names.must_include "Cms::Portlet"

    end
    it "should return all available content types" do
      types = Cms::ContentType.available
      types.first.class.must_equal Cms::ContentType
    end

    it "should be ordered alphabetically" do
      ordered = Cms::ContentType.available
      ordered.first.name.must_equal "AAAFirstBlock"
      ordered.last.name.must_equal "Widget"
    end

  end
end

