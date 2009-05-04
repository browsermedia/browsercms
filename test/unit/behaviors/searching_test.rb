require File.join(File.dirname(__FILE__), '/../../test_helper')

ActiveRecord::Base.connection.instance_eval do
  drop_table(:searchable_content_block_parents) if table_exists?(:searchable_content_block_parents)  
  create_table(:searchable_content_block_parents) {|t| t.string :name }
  drop_table(:searchable_content_blocks) if table_exists?(:searchable_content_blocks)
  drop_table(:searchable_content_block_versions) if table_exists?(:searchable_content_block_versions)
  create_versioned_table(:searchable_content_blocks) do |t| 
    t.integer :parent_id
    t.string :name 
    t.boolean :deleted, :default => 0
    t.integer :created_by
    t.integer :updated_by
    t.timestamps
  end

  # Verifies that blocks are created with a :name column if one is not specified.
  drop_table(:searchable_block_without_names) if table_exists?(:searchable_block_without_names)
  drop_table(:searchable_block_without_name_versions) if table_exists?(:searchable_block_without_name_versions)
  create_versioned_table(:searchable_block_without_names) do |t|
    t.string :title
  end
end

class SearchableContentBlockParent < ActiveRecord::Base
  has_many :children, :class_name => "SearchableContentBlock", :foreign_key => "parent_id" 
end

class SearchableContentBlock < ActiveRecord::Base
  acts_as_content_block
  belongs_to :parent, :class_name => "SearchableContentBlockParent"
  named_scope :created_after, lambda{|time| {:conditions => ["created_at > ?", time]}}
end

class SearchableContentBlockTest < ActiveSupport::TestCase
  def test_searchable
    @parent = SearchableContentBlockParent.create!(:name => "Papa")
    @a1 = @parent.children.create!(:name => "a1")
    @a2 = @parent.children.create!(:name => "a2")
    @b1 = @parent.children.create!(:name => "b1")
    @b2 = @parent.children.create!(:name => "b2")

    assert SearchableContentBlock.searchable?
    assert_equal [@a1, @a2], SearchableContentBlock.search("a").all
    assert_equal [@a2, @a1], SearchableContentBlock.search(:term => "a", :order => "id desc").all
    assert_equal [@a2, @a1], SearchableContentBlock.created_after(1.hour.ago).search(:term => "a", :order => "id desc").all
    assert_equal [@a2, @a1], @parent.children.created_after(1.hour.ago).search(:term => "a", :order => "id desc").all
  end
end

class SearchableHtmlBlockTest < ActiveSupport::TestCase
  def test_searchable
    @a1 = Factory(:html_block, :name => "a1", :content => "a one")
    @a2 = Factory(:html_block, :name => "a2", :content => "a two")
    @b1 = Factory(:html_block, :name => "b1", :content => "b one")
    @b2 = Factory(:html_block, :name => "b2", :content => "b two")

    assert HtmlBlock.searchable?
    assert_equal [@a2, @b2], HtmlBlock.search("2").all
    assert HtmlBlock.search(:term => "one").all.empty?
    assert_equal [@a1, @b1], HtmlBlock.search(:term => "one", :include_body => true).all
    assert HtmlBlock.search(nil).include?(@b2)
  end
end


class SearchableBlockWithoutName < ActiveRecord::Base
  acts_as_content_block
end

class SearchableBlockWithoutNameTest < ActiveSupport::TestCase

  test "Creating a test only ActiveRecord should work" do
    block = SearchableBlockWithoutName.create!(:title => "TITLE")

    assert_not_nil block
    assert_equal block, SearchableBlockWithoutName.find(block.id)
  end

  test "Blocks should have a :name column by default" do
    block = SearchableBlockWithoutName.create!(:name => "NAME")

    assert_equal block, SearchableBlockWithoutName.find_by_name("NAME")
    assert_equal "NAME", block.name
  end
  
  test "Search method should not fail if block has no :name field" do
    block = SearchableBlockWithoutName.create!(:name => ":implicitly specfied")

    assert_equal SearchableBlockWithoutName.all.size, SearchableBlockWithoutName.search({}).size, "Should list all rows when no param is passed in."
  end

  test "Versions table for block should have 'name' attribute as well" do
    name = ":implicitly specfied"
    block = SearchableBlockWithoutName.create!(:name => name)
    block.title = "Something New"
    block.save!

    v1 = block.find_version(1)
    assert_equal name, v1.name
  end
end
