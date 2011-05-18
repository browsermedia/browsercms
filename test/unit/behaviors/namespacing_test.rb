require "test_helper"

create_testing_table :cms_my_blocks
class Cms::MyBlock < ActiveRecord::Base
  uses_namespaced_table
end

create_testing_table :cms_namespaced_blocks
class Cms::NamespacedBlock < ActiveRecord::Base
  acts_as_content_block
end


class Cms::NonNamespacedBlock < ActiveRecord::Base

  # Avoids need to create another table
  set_table_name "cms_namespaced_blocks"

  acts_as_content_block namespace_table: false
end


class Cms::NamespacingCoreRailsTest < ActiveSupport::TestCase

  module ::Foo
    def self.table_name_prefix
      "foobar_"
    end
  end

  class ::Foo::TestBlock < ActiveRecord::Base ; end

  test "table_name should be automatically prefixed" do
    assert_equal "foobar_test_blocks", Foo::TestBlock.table_name
  end


  test "model tables are not automatically prefixed" do
    create_testing_table :test_blocks
    assert_equal false, ActiveRecord::Base.connection.table_exists?("foobar_test_blocks")
  end
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
    class ::Cms::CustomBlock < ActiveRecord::Base
      uses_namespaced_table
    end
    create_testing_table :abc_custom_blocks
    assert_equal "abc_custom_blocks", ::Cms::CustomBlock.new.table_name
  end

  test "Get prefixed name" do
    Cms.expects(:table_prefix).returns('abc_')
    assert_equal "abc_name", Cms::Namespacing.prefixed_table_name("name")
  end

  test "content_blocks should be namespaced by default" do
    assert_equal true, Cms::NamespacedBlock.namespaced_table?
  end

  test "can opt out of namespacing too" do
    assert_equal false, Cms::NonNamespacedBlock.respond_to?(:namespaced_table?)
  end
end
