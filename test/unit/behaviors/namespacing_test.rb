require "test_helper"

create_testing_table :cms_my_blocks

class Cms::MyBlock < ActiveRecord::Base
  namespaces_table
end

class Cms::Behaviors::NamespacingTest < ActiveSupport::TestCase

  def setup
  end


  test "All blocks automatically get namespacing" do
    Cms::MyBlock.respond_to?(:namespaced_table?)
  end

  test "Should be namespaced" do
    assert_equal true, MyBlock.namespaced_table?
  end

  test "default table namespace " do
    assert_equal "cms_my_blocks", MyBlock.new.table_name
  end

  test "set a table namespace" do
    Cms.expects(:table_prefix).returns('abc_')
    class ::CustomBlock < ActiveRecord::Base
      namespaces_table
    end
    create_testing_table :abc_custom_blocks
    assert_equal "abc_custom_blocks", CustomBlock.new.table_name
  end

  test "Get prefixed name" do
    Cms.expects(:table_prefix).returns('abc_')
    assert_equal "abc_name", Cms::Namespacing.prefixed_table_name("name")
  end
end
