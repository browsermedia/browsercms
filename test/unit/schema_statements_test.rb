require 'test_helper'

class SchemaStatementsTest < ActiveSupport::TestCase

  def ensure_no_prefix
    Cms.expects(:table_prefix).returns("").at_least_once
  end

  def setup
    ensure_no_prefix()
    %w(fake_contents).each do |t|
      ActiveRecord::Base.connection.drop_content_table(t) rescue nil
      ActiveRecord::Base.connection.drop_table(t) rescue nil
    end

  end

  test "If available, blocks will use explicit version_column_name" do
    class ::Cms::ExplictColumnBlock < ActiveRecord::Base
      acts_as_content_block :versioned=>{:version_foreign_key => :something_id }
    end
    connection.drop_content_table :explict_column_blocks rescue nil
    connection.create_content_table :explict_column_blocks, :prefix=>false do |t| ; end

    assert_column_exists :explict_column_block_versions, :something_id
  end

  test "Nonversioned blocks shouldn't create versions table" do
    ensure_no_prefix()

    class ::Cms::NonVersionedBlock < ActiveRecord::Base
      acts_as_content_block :versioned=>false
    end
    connection.drop_table :non_versioned_blocks rescue nil
    connection.drop_table :non_versioned_block_versions rescue nil
    connection.create_content_table :non_versioned_blocks, :prefix=>false, :versioned=>false do |t| ; end

    assert_equal false, ActiveRecord::Base.connection.table_exists?(:non_versioned_block_versions)
  end


  test "Create default versioned column, even if the record isn't marked versions (handles subclasses)" do
    class ::Cms::PossiblyVersionedBlock < ActiveRecord::Base
    end
    connection.drop_table :possibly_versioned_blocks rescue nil
    connection.drop_table :possibly_versioned_block_versions rescue nil
    connection.create_content_table :possibly_versioned_blocks, :prefix=>false do |t| ; end

    assert_column_exists :possibly_versioned_block_versions, :possibly_versioned_block_id
  end

  test "non-existant models should create default versions table." do
    ensure_no_prefix()

    connection.drop_table :non_existant_blocks rescue nil
    connection.drop_table :non_existant_block_versions rescue nil
    connection.create_content_table :non_existant_blocks, :prefix=>false do |t| ; end

    assert_column_exists :non_existant_block_versions, :non_existant_block_id
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

    ActiveRecord::Base.connection.instance_eval do
      drop_table('abc_add_prefix') rescue nil
      drop_table('abc_add_prefix_versions') rescue nil
      create_content_table 'add_prefix' do |t|  ;  end
    end

    assert_table_was_created('abc_add_prefix')
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

    assert_table_was_created('stuff')
  end

  private

  def connection
    ActiveRecord::Base.connection
  end

  def assert_table_was_created(table_name)
    result = connection.execute("show tables like '#{table_name}'")
    assert_equal 1, result.count, "Ensure the table was crated. (Might fail when running unit tests with drivers other than mysql2)"
  end
end


