require File.join(File.dirname(__FILE__), '/../test_helper')

class SchemaStatementsTest < ActiveSupport::TestCase

  def teardown
    %w(fake_contents fake_content_versions).each do |table|
      ActiveRecord::Base.connection.drop_table(table) rescue nil
    end
  end

  test "create_content_table should make two tables" do
    conn = ActiveRecord::Base.connection
    conn.create_content_table :fake_contents do |t|
      t.string :name
    end

    expected_columns = %w(archived created_at created_by_id deleted id lock_version name published updated_at updated_by_id version)
    expected_columns_v = %w(archived created_at created_by_id deleted fake_content_id id name published updated_at updated_by_id version version_comment)
    assert_equal expected_columns, conn.columns(:fake_contents).map { |c| c.name }.sort
    assert_equal expected_columns_v, conn.columns(:fake_content_versions).map { |c| c.name }.sort
  end

  test "add_content_column should add columns to both primary and versions table" do
    connection.create_content_table :fake_contents do |t| end

    connection.add_content_column :fake_contents, :foo, :string

    found_c = connection.columns(:fake_contents).map { |c| c.name }
    assert found_c.include?("foo")

    found_c = connection.columns(:fake_content_versions).map { |c| c.name }
    assert found_c.include?("foo")
  end


  def connection
    ActiveRecord::Base.connection
  end
end


