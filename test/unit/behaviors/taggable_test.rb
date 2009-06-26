require File.join(File.dirname(__FILE__), '/../../test_helper')

ActiveRecord::Base.connection.instance_eval do
  drop_table(:taggable_articles) if table_exists?(:taggable_articles)
  create_table(:taggable_articles) {|t| t.string :name }

  drop_table(:versioned_taggable_articles) if table_exists?(:versioned_taggable_articles)
  drop_table(:versioned_taggable_article_versions) if table_exists?(:versioned_taggable_article_versions)
  create_versioned_table(:versioned_taggable_articles) do |t| 
    t.string :name
  end
end

class TaggableArticle < ActiveRecord::Base
  is_taggable
end

class VersionedTaggableArticle < ActiveRecord::Base
  acts_as_content_block :taggable => true
end

class TaggableBlockTest < ActiveSupport::TestCase
  def test_tagging
    article = TaggableArticle.create!(:name => "foo")
    assert_equal 0, article.taggings.count
    assert_equal 0, article.tags.count
    assert_equal 0, Tag.count
    assert_equal 0, Tagging.count

    article.tag_list = "foo bar"
    assert article.save
    assert_equal 2, article.taggings.count
    assert_equal 2, article.tags.count
    assert_equal 2, Tag.count
    assert_equal 2, Tagging.count
    
    assert_equal [article], TaggableArticle.tagged_with("foo").all
    assert_equal [article], TaggableArticle.tagged_with("bar").all
    assert TaggableArticle.tagged_with("bang").all.empty?
        
    article.tag_list = "foo bang"
    assert article.save
    assert_equal 2, article.taggings.count
    assert_equal 2, article.tags.count
    assert_equal 3, Tag.count
    assert_equal 2, Tagging.count

    assert_equal [article], TaggableArticle.tagged_with("foo").all
    assert_equal [article], TaggableArticle.tagged_with("bang").all
    assert TaggableArticle.tagged_with("bar").all.empty?
    
    assert_equal "bang foo", article.tag_list
  end
  
  def test_tag_cloud
    25.times do |n|
      tag_list = ["article"]
      tag_list << "first" if n == 0
      tag_list << "even" if n.even?
      tag_list << "five" if n % 5 == 0
      tag_list << "last" if n == 24
      TaggableArticle.create!(:name => "Article ##{n}", :tag_list => tag_list.join(" ") )
    end
    
    tag_counts = Tag.counts(:limit => 4)
    assert_equal 4, tag_counts.size
    assert_equal Tag.find_by_name("article"), tag_counts[0]
    assert_equal "25", tag_counts[0].count
    assert_equal Tag.find_by_name("even"), tag_counts[1]
    assert_equal "13", tag_counts[1].count
    assert_equal Tag.find_by_name("five"), tag_counts[2]
    assert_equal "5", tag_counts[2].count
    assert_equal Tag.find_by_name("first"), tag_counts[3]
    assert_equal "1", tag_counts[3].count
    
    tag_cloud = Tag.cloud(:sizes => 9)
    assert_equal 5, tag_cloud.size
    assert_equal Tag.find_by_name("article"), tag_cloud[0]
    assert_equal 6, tag_cloud[0].size
    assert_equal Tag.find_by_name("even"), tag_cloud[1]
    assert_equal 3, tag_cloud[1].size
    assert_equal Tag.find_by_name("five"), tag_cloud[2]
    assert_equal 1, tag_cloud[2].size
    assert_equal Tag.find_by_name("first"), tag_cloud[3]
    assert_equal 0, tag_cloud[3].size
    assert_equal Tag.find_by_name("last"), tag_cloud[4]
    assert_equal 0, tag_cloud[4].size
  end
  
end

class VersionedTaggableBlockTest < ActiveSupport::TestCase
  def test_tagging
    article = VersionedTaggableArticle.create!(:name => "foo")
    assert_equal 0, article.taggings.count
    assert_equal 0, article.tags.count
    assert_equal 0, Tag.count
    assert_equal 0, Tagging.count

    article.tag_list = "foo bar"
    assert article.save
    assert_equal 2, article.taggings.count
    assert_equal 2, article.tags.count
    assert_equal 2, Tag.count
    assert_equal 2, Tagging.count
  end

  
end