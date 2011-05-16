require 'test_helper'

class SchemaStatementsTest < ActiveSupport::TestCase

  def setup
    Cms.expects(:table_prefix).returns("").at_least_once
    %w(fake_contents).each do |t|
      ActiveRecord::Base.connection.drop_content_table(t) rescue nil
      ActiveRecord::Base.connection.drop_table(t) rescue nil
    end

  end

  test "prefixed" do
    Cms.expects(:table_prefix).returns("abc_")

    result = ""
    ActiveRecord::Base.connection.instance_eval do
      result = prefix("stuff")
    end

    assert_equal "abc_stuff", result
  end

  test "create_content_table should make two tables" do
    conn = ActiveRecord::Base.connection
    conn.create_content_table :fake_contents, :prefix=>false do |t|
      t.string :name
    end

    expected_columns = %w(archived created_at created_by_id deleted id lock_version name published updated_at updated_by_id version)
    expected_columns_v = %w(archived created_at created_by_id deleted fake_content_id id name published updated_at updated_by_id version version_comment)
    assert_equal expected_columns, conn.columns(:fake_contents).map { |c| c.name }.sort
    assert_equal expected_columns_v, conn.columns(:fake_content_versions).map { |c| c.name }.sort
  end

  test "add_content_column should add columns to both primary and versions table" do

    connection.create_content_table :fake_contents, :prefix=>false do |t|; end

    connection.add_content_column :fake_contents, :foo, :string

    found_c = connection.columns(:fake_contents).map { |c| c.name }
    assert found_c.include?("foo")

    found_c = connection.columns(:fake_content_versions).map { |c| c.name }
    assert found_c.include?("foo")
  end

  test "create_content_table should automatically add prefix" do
    Cms.expects(:table_prefix).returns("abc_").at_least_once

    name = 'add_prefix'
    ActiveRecord::Base.connection.instance_eval do
      drop_content_table(name) if content_table_exists?(name)
      create_content_table name do |t|
      end
    end

    result = connection.execute("show tables like 'abc_add_prefix'")
    assert_equal 1, result.num_rows, "Might fail on non-mysql"

  end

  test "Can optionally not create prefixed table" do
    Cms.expects(:table_prefix).never

    name = 'stuff'
    ActiveRecord::Base.connection.instance_eval do
      drop_table("stuff_versions") if table_exists?("stuff_versions")
      drop_table("stuff") if table_exists?("stuff")
      create_content_table name, :prefix=>false do |t|
      end
    end

    result = connection.execute("show tables like 'stuff'")
    assert_equal 1, result.num_rows, "Might fail on non-mysql"
  end

  private
  def connection
    ActiveRecord::Base.connection
  end
end


