require "test_helper"

# Needs explicit requirement since its included into only seeds that need it.
require 'cms/data_loader'

module Cms
  class DataLoaderTest < ActiveSupport::TestCase
    include DataLoader

    def setup
      DataLoader.silent_mode = true
    end

    def teardown
      DataLoader.silent_mode = false
    end

    test "#create_html_block" do
      block = create_html_block(:a, name: "hello")
      assert_equal "hello", block.name
      assert block.persisted?
    end

    test "#create_dynamic_portlet" do
      portlet = create_dynamic_portlet(:a, name: "Bravo")
      assert_equal "Bravo", portlet.name
    end

    test "#create_string" do
      error = assert_raise RuntimeError do
        create_string(:a, name: "Charlie")
      end
      assert_equal "Can't create an instance of String because its not an ActiveRecord instance.", error.message
    end
  end
end