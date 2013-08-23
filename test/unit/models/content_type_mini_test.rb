require "minitest_helper"

class Widget < ActiveRecord::Base
  acts_as_content_block
end


class AAAFirstBlock < ActiveRecord::Base
  acts_as_content_block
end

def given_login_portlet_has_been_loaded_as_constant_by_rails
  LoginPortlet
end

describe Cms::ContentType do
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

